import 'dart:async';

/// A `watch*()` stream backed by a plain GET.
///
/// `BACKEND_INTEGRATION.md` §3 states the hardest contract in the app:
///
/// > Every `watch*()` stream must emit its current value immediately on
/// > subscribe, then emit again on every change.
///
/// and
///
/// > Streams must tolerate multiple and repeated subscriptions.
///
/// Both are load-bearing. The providers are `autoDispose`, so navigating away
/// and back resubscribes; and `everyday_hours_sheet.dart` calls
/// `watchOpenHours().first`, which hangs forever against a stream that only
/// pushes future deltas.
///
/// This satisfies both: [watch] emits the cached-or-fetched value first, then
/// forwards a broadcast stream of subsequent changes. [refresh] is called
/// after every mutation, which is what closes the loop for fire-and-forget
/// writes — the UI never applies a change locally, it waits for the stream.
///
/// Changes made by ANOTHER manager on another iPad do not arrive until
/// something here refetches. The playback increment adds a server-push channel;
/// until then this is single-client-correct, which is what the settings and
/// venue screens actually need.
class Watchable<T> {
  Watchable(this._fetch, {this.scopeKey});

  final Future<T> Function() _fetch;

  /// Identifies what the cached value is *of* — the current zone or venue.
  /// When it changes the cache is stale by definition, so it is dropped rather
  /// than served for the wrong room.
  final String? Function()? scopeKey;

  final _controller = StreamController<T>.broadcast();

  T? _cached;
  String? _cachedScope;
  Future<T>? _inFlight;

  /// Emits the current value, then every change.
  ///
  /// Deliberately NOT an `async*` generator. `yield await _current()` followed
  /// by `yield* _controller.stream` reads well but has two faults that cost a
  /// whole session of debugging:
  ///
  /// 1. A throw from the first fetch ENDS the stream. The router subscribes to
  ///    guardrails at startup, before sign-in, when there is no current zone —
  ///    so the fetch throws, the stream dies, and nothing reaches that listener
  ///    ever again. Settings then renders fallback defaults forever, and a
  ///    slider appears frozen because the value it displays can never change.
  /// 2. There is an async gap between the two yields, so a change arriving
  ///    mid-fetch is dropped.
  ///
  /// Subscribing to the change feed FIRST, then fetching, fixes both: an error
  /// is surfaced to the listener without unsubscribing it, and a later
  /// [refresh] or [emit] still lands.
  Stream<T> watch() {
    final out = StreamController<T>();
    StreamSubscription<T>? relay;

    out.onListen = () {
      relay = _controller.stream.listen(
        (value) {
          if (!out.isClosed) out.add(value);
        },
        onError: (Object error, StackTrace stack) {
          if (!out.isClosed) out.addError(error, stack);
        },
      );
      _current().then(
        (value) {
          if (!out.isClosed) out.add(value);
        },
        onError: (Object error, StackTrace stack) {
          // Surfaced, not fatal — the subscription above stays live.
          if (!out.isClosed) out.addError(error, stack);
        },
      );
    };
    out.onCancel = () async {
      await relay?.cancel();
      relay = null;
    };
    return out.stream;
  }

  /// The current value, fetching at most once even if several subscribers
  /// arrive in the same frame — the Floor screen mounts three watchers at once.
  Future<T> _current() {
    final scope = scopeKey?.call();
    if (scope != _cachedScope) {
      _cached = null;
      _cachedScope = scope;
    }

    final cached = _cached;
    if (cached != null) return Future.value(cached);

    return _inFlight ??= _fetch().then(
      (value) {
        _cached = value;
        _inFlight = null;
        return value;
      },
      onError: (Object error, StackTrace stack) {
        // Not cached: a failed fetch must not become the permanent answer, and
        // the next subscriber must be free to try again.
        _inFlight = null;
        throw error;
      },
    );
  }

  /// Refetch and push to every listener. Call after a successful mutation.
  Future<void> refresh() async {
    final next = await _fetch();
    _cached = next;
    _cachedScope = scopeKey?.call();
    if (!_controller.isClosed) _controller.add(next);
  }

  /// Push a value we already have, without a round trip.
  void emit(T value) {
    _cached = value;
    _cachedScope = scopeKey?.call();
    if (!_controller.isClosed) _controller.add(value);
  }

  void dispose() => _controller.close();
}
