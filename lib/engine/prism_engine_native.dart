/// The engine on platforms with `dart:ffi` — iPad, Android, Windows, macOS.
///
/// Wraps `prism_core_bindings` and adds the two things a Flutter app needs that
/// the bindings deliberately do not provide:
///
/// 1. **Assets become files.** The C ABI takes a filesystem PATH to a scene
///    manifest and resolves stems relative to it. Flutter assets are not files
///    on device — they live inside the app bundle — so they are copied once
///    into the app-support directory and the engine is pointed there.
///
/// 2. **Mood means scene.** Each of the six moods has its own manifest with its
///    own stems, so switching mood means loading a different scene.
///
/// ## The gap on mood change, stated honestly
///
/// `prism_load_scene` is rejected after `prism_start` — scenes are loaded once,
/// with all decoding done up front so the render path never touches disk. So a
/// mood change here is stop → load → start, which costs a short silence while
/// the new stems decode.
///
/// The engine's own spec describes scene changes as equal-power crossfades
/// scheduled at loop boundaries, which is what the app's Seamless / Gentle /
/// Lively setting is meant to control. That needs the engine to hold more than
/// one scene at a time, which it currently cannot (`Pgae` owns exactly one
/// `SceneAssets`, and `mode_hint` does not select scenes yet). Until that lands,
/// this is the honest behaviour, and the Seamless setting is not yet honoured.
///
/// The alternative — one shared scene for all six moods, switched purely by
/// pinning the PSV — is seamless but much less distinct: measured on a single
/// scene, the loudest and quietest moods land within ~2.6 dB, because most of
/// the separation between the six comes from their different stem sets. Given
/// the requirement is that the six must not sound alike, the brief gap is the
/// better trade for now.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:prism_core_bindings/prism_core_bindings.dart';

import 'prism_engine.dart';

/// Where the bundled scenes live in the asset tree.
const _assetDir = 'assets/audio';

/// Manifest per mood id. Ids match `theme/moods.dart` and the backend.
const _manifests = <String, String>{
  'morning-calm': 'mood_morning_calm.json',
  'daytime-flow': 'mood_daytime_flow.json',
  'afternoon-lift': 'mood_afternoon_lift.json',
  'evening-warmth': 'mood_evening_warmth.json',
  'peak': 'mood_peak.json',
  'wind-down': 'mood_wind_down.json',
};

class PlatformPrismEngine implements PrismEngine {
  PrismCore? _core;
  Directory? _sceneDir;

  String? _currentMood;
  bool _silenced = false;

  EngineStatus _status = EngineStatus.idle;
  String? _lastError;
  final _statusController = StreamController<EngineStatus>.broadcast();

  /// Serialises engine work. Mood taps can arrive faster than a scene loads,
  /// and overlapping stop/load/start sequences would corrupt the lifecycle.
  Future<void> _queue = Future.value();

  @override
  EngineStatus get status => _status;

  @override
  String? get lastError => _lastError;

  @override
  Stream<EngineStatus> get statusChanges => _statusController.stream;

  void _setStatus(EngineStatus s, [String? error]) {
    _lastError = error;
    if (_status == s) return;
    _status = s;
    if (!_statusController.isClosed) _statusController.add(s);
  }

  /// Runs [action] after everything already queued, swallowing failures into
  /// [status]. The dashboard must keep working when audio does not.
  Future<void> _serialise(String what, Future<void> Function() action) {
    final next = _queue.then((_) async {
      try {
        await action();
      } catch (e) {
        _setStatus(EngineStatus.failed, '$what failed: $e');
        debugPrint('prism engine: $what failed: $e');
      }
    });
    // Keep the chain alive even if a link failed, or every later call hangs.
    _queue = next.catchError((_) {});
    return next;
  }

  @override
  Future<void> start() => _serialise('start', () async {
        if (_core != null) return;
        _setStatus(EngineStatus.starting);
        _sceneDir ??= await _extractScenes();
        _core = PrismCore.create(vertical: PrismVertical.venues);
        // No scene yet: the first setMood loads one. Starting without a scene
        // would be rejected by the ABI, and there is no sensible default —
        // the room's mood comes from the backend.
      });

  @override
  Future<void> setMood(String moodId) => _serialise('setMood($moodId)', () async {
        final manifest = _manifests[moodId];
        if (manifest == null) {
          debugPrint('prism engine: unknown mood "$moodId" ignored');
          return;
        }
        if (moodId == _currentMood && _core != null) return;

        final mood = VenueMood.byId(moodId);
        if (mood == null) {
          debugPrint('prism engine: no preset for "$moodId" ignored');
          return;
        }

        final core = _core;
        if (core == null) return; // start() not called or it failed

        // Scenes load once per engine lifetime, so a mood change is a full
        // reload. See the library doc for why this gap exists.
        core.deviceStop();
        core.stop();
        core.loadScene('${_sceneDir!.path}/$manifest');
        core.start();
        core.setMoodOverride(mood);
        _currentMood = moodId;

        if (_silenced) {
          _setStatus(EngineStatus.silenced);
        } else {
          core.deviceStart();
          _setStatus(EngineStatus.playing);
        }
      });

  @override
  Future<void> silence() => _serialise('silence', () async {
        _silenced = true;
        _core?.deviceStop();
        _setStatus(EngineStatus.silenced);
      });

  @override
  Future<void> resume() => _serialise('resume', () async {
        _silenced = false;
        final core = _core;
        if (core == null || _currentMood == null) return;
        core.deviceStart();
        _setStatus(EngineStatus.playing);
      });

  @override
  Future<void> dispose() => _serialise('dispose', () async {
        _core?.dispose();
        _core = null;
        await _statusController.close();
      });

  /// Copies the bundled manifests and stems into a real directory once.
  ///
  /// Keyed by a manifest of what was written: if the app ships new stems, the
  /// marker no longer matches and everything is re-extracted. Without that, an
  /// update would silently keep playing the old audio.
  Future<Directory> _extractScenes() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/prism_scenes');

    final index = await rootBundle.loadString('$_assetDir/index.txt');
    final files = index
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();

    final marker = File('${dir.path}/.extracted');
    if (await marker.exists() && await marker.readAsString() == index) {
      return dir;
    }

    await dir.create(recursive: true);
    for (final rel in files) {
      final data = await rootBundle.load('$_assetDir/$rel');
      final out = File('${dir.path}/$rel');
      await out.parent.create(recursive: true);
      await out.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }
    await marker.writeAsString(index, flush: true);
    return dir;
  }
}
