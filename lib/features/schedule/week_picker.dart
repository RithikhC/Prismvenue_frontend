import 'package:flutter/material.dart';

import '../../shared/widgets/prism_icons.dart';
import '../../shared/widgets/prism_top_bar.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// S03-3 "Jump to another week — tap the date to open the calendar".
/// Calendar popover: month grid, today ringed, selected filled accent.
/// Resolves with the picked date (the screen jumps to its week). Popover
/// anchoring and month chevrons are derived, not pinned (open_questions).
Future<DateTime?> showWeekPicker(BuildContext context,
    {required DateTime selected}) {
  return showDialog<DateTime>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (dialogContext) => Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: PrismTopBar.height + 66, left: 15),
        child: Material(
          color: Colors.transparent,
          child: _CalendarPopover(selected: selected),
        ),
      ),
    ),
  );
}

class _CalendarPopover extends StatefulWidget {
  const _CalendarPopover({required this.selected});

  final DateTime selected;

  @override
  State<_CalendarPopover> createState() => _CalendarPopoverState();
}

class _CalendarPopoverState extends State<_CalendarPopover> {
  late DateTime _month =
      DateTime(widget.selected.year, widget.selected.month);

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final today = DateTime.now();
    final firstWeekday = _month.weekday; // 1 = Mon
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    return Container(
      width: 292,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x59000000), blurRadius: 40, offset: Offset(0, 18)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('${_monthNames[_month.month - 1]} ${_month.year}',
                  style: PrismType.bodySm
                      .copyWith(fontSize: 13, color: palette.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(
                    () => _month = DateTime(_month.year, _month.month - 1)),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: PrismChevron(
                      direction: ChevronDirection.left,
                      size: 13,
                      color: palette.textSecondary),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(
                    () => _month = DateTime(_month.year, _month.month + 1)),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: PrismChevron(
                      direction: ChevronDirection.right,
                      size: 13,
                      color: palette.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                Expanded(
                  child: Text(d,
                      textAlign: TextAlign.center,
                      style: PrismType.micro
                          .copyWith(color: palette.textTertiary)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var week = 0; week * 7 < firstWeekday - 1 + daysInMonth; week++)
            Row(
              children: [
                for (var dow = 0; dow < 7; dow++)
                  Expanded(
                    child: Builder(builder: (context) {
                      final dayNum = week * 7 + dow - (firstWeekday - 1) + 1;
                      if (dayNum < 1 || dayNum > daysInMonth) {
                        return const SizedBox(height: 34);
                      }
                      final date =
                          DateTime(_month.year, _month.month, dayNum);
                      final isToday = date.year == today.year &&
                          date.month == today.month &&
                          date.day == today.day;
                      final isSelected = date.year == widget.selected.year &&
                          date.month == widget.selected.month &&
                          date.day == widget.selected.day;
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(date),
                        child: Container(
                          height: 34,
                          margin: const EdgeInsets.all(1),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? palette.accent : Colors.transparent,
                            border: isToday && !isSelected
                                ? Border.all(color: palette.accent)
                                : null,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text('$dayNum',
                              style: PrismType.bodySm.copyWith(
                                  fontSize: 12,
                                  color: isSelected
                                      ? palette.chipInk
                                      : palette.textPrimary)),
                        ),
                      );
                    }),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
