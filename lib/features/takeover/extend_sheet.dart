import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/takeover_state.dart';
import '../../data/repositories/playback_repo.dart';
import '../../data/repositories/settings_repo.dart';
import '../../shared/widgets/error_note.dart';
import '../../shared/widgets/pressable.dart';
import '../../shared/widgets/prism_bottom_sheet.dart';
import '../../shared/widgets/prism_top_bar.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// S02-4 "More time — your audio keeps playing, Prism just waits longer".
///
/// Built to the frame: the current return time, +15/+30/+1 hour chips, an
/// "Until we close" row fed by the venue's open hours, a live "New return"
/// preview, "Push it back" as the CTA, and "Remove auto-return instead"
/// beneath it.
Future<void> showExtendSheet(BuildContext context, WidgetRef ref) async {
  final result = await showPrismSheet<_ExtendResult>(
    context,
    topBarHeight: PrismTopBar.height,
    sheet: const _ExtendSheet(),
  );
  if (result == null) return;
  try {
    switch (result) {
      case _Extend(:final by):
        await ref.read(playbackRepoProvider).extendTakeover(by);
      case _RemoveAutoReturn():
        await ref.read(playbackRepoProvider).removeAutoReturn();
    }
  } catch (e) {
    if (context.mounted) showPrismError(context, e);
  }
}

sealed class _ExtendResult {}

class _Extend extends _ExtendResult {
  _Extend(this.by);
  final Duration by;
}

class _RemoveAutoReturn extends _ExtendResult {}

/// The three quick additions from the frame. "Until we close" is computed
/// per-venue, so it lives outside this list.
const _chips = [
  ('+15 min', Duration(minutes: 15)),
  ('+30 min', Duration(minutes: 30)),
  ('+1 hour', Duration(hours: 1)),
];

class _ExtendSheet extends ConsumerStatefulWidget {
  const _ExtendSheet();

  @override
  ConsumerState<_ExtendSheet> createState() => _ExtendSheetState();
}

class _ExtendSheetState extends ConsumerState<_ExtendSheet> {
  var _index = 1; // +30 min — the frame's selected default
  var _untilClose = false;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;

    // Live: the repos tick once a second, so "in 1:48" and the preview stay
    // current while the sheet is open.
    final remaining =
        ref.watch(takeoverStateProvider).value?.remaining ?? Duration.zero;
    final closeHour = ref.watch(openHoursProvider).value?.closeHour;

    final now = DateTime.now();
    final currentReturn = now.add(remaining);

    // Today's close as an instant. A close hour at/before now means "closes
    // after midnight" (or already passed) — either way, tomorrow's.
    DateTime? closeTime;
    Duration? untilCloseAddition;
    if (closeHour != null) {
      var close = DateTime(now.year, now.month, now.day, closeHour);
      if (!close.isAfter(now)) close = close.add(const Duration(days: 1));
      closeTime = close;
      final addition = close.difference(currentReturn);
      // Selectable only if it actually pushes the return LATER — extending to
      // before the current return would be a shortening in disguise.
      if (addition > Duration.zero) untilCloseAddition = addition;
    }

    final chosen =
        _untilClose ? (untilCloseAddition ?? Duration.zero) : _chips[_index].$2;
    final newReturn = currentReturn.add(chosen);

    return PrismBottomSheet(
      title: 'More time',
      sub: 'Your audio keeps playing — Prism just waits longer.',
      primaryLabel: 'Push it back',
      onPrimary: chosen > Duration.zero
          ? () => Navigator.of(context).pop(_Extend(chosen))
          : null,
      onCancel: () => Navigator.of(context).pop(),
      footer: Column(
        children: [
          Pressable(
            onTap: () => Navigator.of(context).pop(_RemoveAutoReturn()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Text('Remove auto-return instead',
                  style: PrismType.button
                      .copyWith(fontSize: 12.5, color: palette.amber)),
            ),
          ),
          const SizedBox(height: 2),
          Text("you'll have to bring Prism back yourself",
              style: PrismType.microHelper
                  .copyWith(color: palette.textSecondary)),
        ],
      ),
      children: [
        const SizedBox(height: 6),
        Text(
          'Currently returns ${TakeoverState.clockLabel(currentReturn)}'
          ' · in ${TakeoverState.formatDuration(remaining)}',
          style: PrismType.meta.copyWith(
              fontSize: 11, color: palette.textSecondary),
        ),
        const SizedBox(height: 16),
        Text('Add time',
            style: PrismType.label.copyWith(color: palette.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final (i, (label, _)) in _chips.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              _Chip(
                label: label,
                selected: !_untilClose && _index == i,
                onTap: () => setState(() {
                  _index = i;
                  _untilClose = false;
                }),
              ),
            ],
          ],
        ),
        if (closeTime != null) ...[
          const SizedBox(height: 10),
          _UntilCloseRow(
            closeLabel: TakeoverState.clockLabel(closeTime),
            selected: _untilClose,
            // Inert (40%) when closing time no longer pushes the return later.
            onTap: untilCloseAddition == null
                ? null
                : () => setState(() => _untilClose = true),
          ),
        ],
        const SizedBox(height: 14),
        // "New return" preview — the sheet's answer before you commit.
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: BoxDecoration(
            color: palette.accentSoft,
            border: Border.all(color: palette.accent),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New return',
                  style: PrismType.meta.copyWith(
                      fontSize: 10.5, color: palette.textSecondary)),
              const SizedBox(height: 3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(TakeoverState.clockLabel(newReturn),
                      style: PrismType.body.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: palette.textPrimary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'in ${TakeoverState.formatDuration(remaining + chosen)}'
                      ' · was ${TakeoverState.clockLabel(currentReturn)}',
                      style: PrismType.meta.copyWith(
                          fontSize: 11, color: palette.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pill chip — r999, accentSoft + accent border when selected.
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? palette.accentSoft : palette.tile,
          border:
              Border.all(color: selected ? palette.accent : palette.border),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: PrismType.bodySm.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color:
                    selected ? palette.accentText : palette.textPrimary)),
      ),
    );
  }
}

/// "Until we close · 11:00 pm" — a fourth option shaped as a full-width row.
class _UntilCloseRow extends StatelessWidget {
  const _UntilCloseRow({
    required this.closeLabel,
    required this.selected,
    this.onTap,
  });

  final String closeLabel;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return Pressable(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? .4 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
          decoration: BoxDecoration(
            color: selected ? palette.accentSoft : palette.tile,
            border:
                Border.all(color: selected ? palette.accent : palette.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text('Until we close',
                  style: PrismType.body.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? palette.accentText
                          : palette.textPrimary)),
              const Spacer(),
              Text(closeLabel,
                  style: PrismType.bodySm.copyWith(
                      fontSize: 13, color: palette.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
