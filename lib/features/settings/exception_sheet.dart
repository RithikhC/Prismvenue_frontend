import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/guardrails.dart';
import '../../data/repositories/settings_repo.dart';
import '../../shared/widgets/day_chips.dart';
import '../../shared/widgets/prism_bottom_sheet.dart';
import '../../shared/widgets/prism_toggle.dart';
import '../../shared/widgets/prism_top_bar.dart';
import '../../shared/widgets/seg_toggle.dart';
import '../../shared/widgets/settings_row.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'widgets/time_field.dart';

/// S05-10 "Add an exception — pick days, hours & repeat". BottomSheet:
/// sub "Different hours for some days — everything else keeps the
/// default."; Which days — DayChips (Fri & Sat selected); Hours — Opens
/// "7:00 am" / Closes "1:00 am" fields + "Tap a time to set it on the
/// dial."; "Closed all day" toggle row + "e.g. a public holiday"; Repeat
/// seg Just this once / [Every week]; Cancel / "Add exception" (1:2).
Future<void> showExceptionSheet(BuildContext context, WidgetRef ref) async {
  final exception = await showPrismSheet<HoursException>(
    context,
    topBarHeight: PrismTopBar.height,
    sheet: const _ExceptionSheet(),
  );
  if (exception != null) {
    await ref.read(settingsRepoProvider).addException(exception);
  }
}

class _ExceptionSheet extends StatefulWidget {
  const _ExceptionSheet();

  @override
  State<_ExceptionSheet> createState() => _ExceptionSheetState();
}

class _ExceptionSheetState extends State<_ExceptionSheet> {
  final _days = <int>{4, 5}; // Fri & Sat per the frame
  var _open = 7;
  var _close = 1; // 1:00 am
  var _closedAllDay = false;
  var _everyWeek = true;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return PrismBottomSheet(
      title: 'Add an exception',
      sub: 'Different hours for some days — everything else keeps the '
          'default.',
      primaryLabel: 'Add exception',
      onPrimary: _days.isEmpty
          ? null
          : () => Navigator.of(context).pop(HoursException(
                days: Set.of(_days),
                openHour: _open,
                closeHour: _close,
                closedAllDay: _closedAllDay,
                everyWeek: _everyWeek,
              )),
      onCancel: () => Navigator.of(context).pop(),
      children: [
        const SizedBox(height: 16),
        Text('Which days',
            style: PrismType.label.copyWith(color: palette.textSecondary)),
        const SizedBox(height: 8),
        DayChips(
          selected: _days,
          onToggle: (i) => setState(
              () => _days.contains(i) ? _days.remove(i) : _days.add(i)),
        ),
        const SizedBox(height: 14),
        Text('Hours',
            style: PrismType.label.copyWith(color: palette.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TimeField(
                label: 'Opens',
                hour: _open,
                dialTitle: 'Opening time',
                onChanged: (h) => setState(() => _open = h),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TimeField(
                label: 'Closes',
                hour: _close,
                dialTitle: 'Closing time',
                onChanged: (h) => setState(() => _close = h),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text('Tap a time to set it on the dial.',
            style:
                PrismType.microHelper.copyWith(color: palette.textSecondary)),
        const SizedBox(height: 14),
        SettingsRow(
          title: 'Closed all day',
          sub: 'e.g. a public holiday',
          chevron: false,
          trailing: PrismToggle(
            on: _closedAllDay,
            onChanged: (on) => setState(() => _closedAllDay = on),
          ),
        ),
        const SizedBox(height: 14),
        Text('Repeat',
            style: PrismType.label.copyWith(color: palette.textSecondary)),
        const SizedBox(height: 8),
        SegToggle(
          options: const ['Just this once', 'Every week'],
          selected: _everyWeek ? 1 : 0,
          onChanged: (i) => setState(() => _everyWeek = i == 1),
        ),
      ],
    );
  }
}
