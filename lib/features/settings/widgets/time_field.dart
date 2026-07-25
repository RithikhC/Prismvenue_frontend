import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/widgets/prism_top_bar.dart';
import '../../../shared/widgets/prism_bottom_sheet.dart';
import '../../../shared/widgets/time_dial_sheet.dart';
import '../../../theme/palette.dart';
import '../../../theme/typography.dart';

/// Labelled tappable time field — S05-10 "Opens 7:00 am (borderStrong +
/// accent clock icon)"; S05-11 uses the same fields with 16/800 values.
/// Tap opens the S05-12 time dial and resolves the picked hour.
class TimeField extends StatelessWidget {
  const TimeField({
    super.key,
    required this.label,
    required this.hour,
    required this.dialTitle,
    required this.onChanged,
    this.big = false,
  });

  final String label;

  /// 0–23.
  final int hour;

  /// "Opening time" / "Closing time" (S05-12 header).
  final String dialTitle;

  final ValueChanged<int> onChanged;

  /// S05-11 variant: value 16/800.
  final bool big;

  static String hourLabel(int h) {
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:00 ${h < 12 ? 'am' : 'pm'}';
  }

  Future<void> _openDial(BuildContext context) async {
    final picked = await showPrismSheet<int>(
      context,
      topBarHeight: PrismTopBar.height,
      sheet: Builder(
        builder: (sheetContext) => TimeDialSheet(
          title: dialTitle,
          initialHour: hour,
          onSet: (h) => Navigator.of(sheetContext).pop(h),
          onCancel: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: PrismType.label.copyWith(color: palette.textSecondary)),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: () => _openDial(context),
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: big ? 12 : 10, horizontal: 13),
            decoration: BoxDecoration(
              color: palette.tile,
              border: Border.all(color: palette.borderStrong),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.clock, size: 15, color: palette.accent),
                const SizedBox(width: 9),
                Text(
                  hourLabel(hour),
                  style: big
                      ? PrismType.body.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: palette.textPrimary)
                      : PrismType.bodySm
                          .copyWith(fontSize: 13, color: palette.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
