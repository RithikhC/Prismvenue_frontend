import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/playback_repo.dart';
import '../../shared/widgets/prism_bottom_sheet.dart';
import '../../shared/widgets/prism_top_bar.dart';
import '../../shared/widgets/seg_toggle.dart';
import 'takeover_screen.dart' show takeoverDurations;

/// S02-4 "Extend — your audio keeps playing, Prism just waits longer".
/// BottomSheet: title "Extend takeover", duration seg (same values),
/// confirm "Extend" → S02-2 with updated countdown (§6-A7: adds the
/// chosen duration).
Future<void> showExtendSheet(BuildContext context, WidgetRef ref) async {
  final duration = await showPrismSheet<Duration>(
    context,
    topBarHeight: PrismTopBar.height,
    sheet: const _ExtendSheet(),
  );
  if (duration != null) {
    await ref.read(playbackRepoProvider).extendTakeover(duration);
  }
}

class _ExtendSheet extends StatefulWidget {
  const _ExtendSheet();

  @override
  State<_ExtendSheet> createState() => _ExtendSheetState();
}

class _ExtendSheetState extends State<_ExtendSheet> {
  var _index = 1; // 30 mins, matching the S02-1 default

  @override
  Widget build(BuildContext context) {
    return PrismBottomSheet(
      title: 'Extend takeover',
      // Sub copy from the frame caption — unverified (open_questions).
      sub: 'Your audio keeps playing, Prism just waits longer.',
      primaryLabel: 'Extend',
      onPrimary: () =>
          Navigator.of(context).pop(takeoverDurations[_index].$3),
      onCancel: () => Navigator.of(context).pop(),
      children: [
        const SizedBox(height: 16),
        SegToggle(
          options: [for (final (label, _, _) in takeoverDurations) label],
          selected: _index,
          onChanged: (i) => setState(() => _index = i),
        ),
      ],
    );
  }
}
