import 'package:flutter/material.dart';

import '../../data/models/schedule_entry.dart';
import '../../theme/moods.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'status_pill.dart';

/// Today's-schedule rail on Floor — §2 S01-1: w268 fixed, border-left 1px
/// `border`, bg `surface`, padding 18. Header mb14: "TODAY'S SCHEDULE"
/// labelCaps + "Auto" chip. Rows gap 16: time 11/700 `textSecondary` w34 +
/// mood dot 8 + name 12. Past rows opacity .42. Current row: bg `accentSoft`,
/// border 1px `accent`, r10, padding 8×9, margin-h −3, time `accentText` 800,
/// name 12.5/700, trailing NOW badge. Next row: trailing "up next" 10
/// `textTertiary`.
class ScheduleRail extends StatelessWidget {
  const ScheduleRail({
    super.key,
    required this.entries,
    required this.nowIndex,
    this.horizontal = false,
  });

  final List<ScheduleEntry> entries;
  final int nowIndex;

  /// §6-A1 portrait: the rail "moves below the mood grid as a horizontal
  /// strip" — same header + rows rendered as a scrollable strip (derived;
  /// portrait is not drawn).
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final b = palette.brightness;

    if (horizontal) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(color: palette.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TODAY'S SCHEDULE",
                    style: PrismType.labelCaps
                        .copyWith(color: palette.textSecondary)),
                const StatusPill(text: 'Auto'),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < entries.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _stripEntry(palette, b, i),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget row(int i) {
      final entry = entries[i];
      final mood = moodById(entry.moodId);
      final current = i == nowIndex;
      final past = i < nowIndex;
      final next = i == nowIndex + 1;

      final content = Row(
        children: [
          SizedBox(
            // The frame pinned w34 for bare "7:00" labels; the meridiem
            // ("11:00 pm") exists because 07:00 and 19:00 rendered
            // identically once evening dayparts arrived, and it needs the
            // extra room.
            width: 52,
            child: Text(
              entry.timeLabel,
              style: PrismType.label.copyWith(
                fontSize: 11,
                fontWeight: current ? FontWeight.w800 : FontWeight.w700,
                color: current ? palette.accentText : palette.textSecondary,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: mood.dot(b), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mood.name,
              style: current
                  ? PrismType.button
                      .copyWith(fontSize: 12.5, color: palette.textPrimary)
                  : PrismType.meta.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary),
            ),
          ),
          if (current)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
              decoration: BoxDecoration(
                color: palette.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('NOW',
                  style: PrismType.nowBadge.copyWith(color: palette.chipInk)),
            )
          else if (next)
            // §1.4 micro band floor is 600 — no 10px/400 style exists.
            Text('up next',
                style: PrismType.micro.copyWith(
                    fontWeight: FontWeight.w600, color: palette.textTertiary)),
        ],
      );

      // CSS margin-h −3 on the current row: the rail pads 15 and normal rows
      // add 3, so the current row bleeds 3px past its siblings on both sides.
      if (current) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 9),
          decoration: BoxDecoration(
            color: palette.accentSoft,
            border: Border.all(color: palette.accent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: content,
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Opacity(opacity: past ? .42 : 1, child: content),
      );
    }

    return Container(
      width: 268,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(left: BorderSide(color: palette.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TODAY'S SCHEDULE",
                    style:
                        PrismType.labelCaps.copyWith(color: palette.textSecondary)),
                const StatusPill(text: 'Auto'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            row(i),
          ],
        ],
      ),
    );
  }

  /// One compact chip of the portrait strip: time + dot + name (+ NOW).
  Widget _stripEntry(PrismPalette palette, Brightness b, int i) {
    final entry = entries[i];
    final mood = moodById(entry.moodId);
    final current = i == nowIndex;
    final past = i < nowIndex;

    final chip = Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      decoration: BoxDecoration(
        color: current ? palette.accentSoft : palette.tile,
        border:
            Border.all(color: current ? palette.accent : palette.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            entry.timeLabel,
            style: PrismType.label.copyWith(
              fontSize: 11,
              fontWeight: current ? FontWeight.w800 : FontWeight.w700,
              color: current ? palette.accentText : palette.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: mood.dot(b), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            mood.name,
            style: current
                ? PrismType.button
                    .copyWith(fontSize: 12.5, color: palette.textPrimary)
                : PrismType.meta.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary),
          ),
          if (current) ...[
            const SizedBox(width: 7),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
              decoration: BoxDecoration(
                color: palette.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('NOW',
                  style:
                      PrismType.nowBadge.copyWith(color: palette.chipInk)),
            ),
          ],
        ],
      ),
    );
    return Opacity(opacity: past ? .42 : 1, child: chip);
  }
}
