import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'prism_bottom_sheet.dart';
import 'seg_toggle.dart';

/// Time dial — §2 S05-12: header title + AM/PM seg (pill, item padding 6×14);
/// readout 58/800 + meridiem 22/700 `textSecondary`; slider track h6 r999
/// `tile2` with accent fill (hour/24 — 7:00 → 29%) and a 26 white thumb with
/// a 4px accent ring + shadow; tick labels 12 am · 6 am · Noon · 6 pm ·
/// 12 am (10.5/600 `textTertiary`); quick chips 7:00–10:00 (gap 7,
/// padding-v 9, r9; selected: `accentSoft` bg, accent border, `accentText`);
/// Cancel / "Set 7:00 AM". Whole-hour granularity (frames show only whole
/// hours — §6-B3).
class TimeDialSheet extends StatefulWidget {
  const TimeDialSheet({
    super.key,
    required this.title,
    required this.initialHour,
    this.onSet,
    this.onCancel,
  });

  /// e.g. "Opening time".
  final String title;

  /// 0–23.
  final int initialHour;

  final ValueChanged<int>? onSet;
  final VoidCallback? onCancel;

  @override
  State<TimeDialSheet> createState() => _TimeDialSheetState();
}

class _TimeDialSheetState extends State<TimeDialSheet> {
  late int _hour = widget.initialHour;

  bool get _pm => _hour >= 12;
  int get _display12 => _hour % 12 == 0 ? 12 : _hour % 12;
  String get _label => '$_display12:00 ${_pm ? 'PM' : 'AM'}';

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;

    return PrismBottomSheet(
      title: widget.title,
      headerTrailing: SegToggle(
        options: const ['AM', 'PM'],
        selected: _pm ? 1 : 0,
        pill: true,
        itemPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        onChanged: (i) => setState(() {
          if (i == 0 && _pm) _hour -= 12;
          if (i == 1 && !_pm) _hour += 12;
        }),
      ),
      primaryLabel: 'Set $_label',
      onPrimary: widget.onSet == null ? null : () => widget.onSet!(_hour),
      onCancel: widget.onCancel,
      children: [
        const SizedBox(height: 18),
        // Readout: "7:00" 58/800 + "AM" 22/700 textSecondary.
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$_display12:00',
                  style: PrismType.numeralDial
                      .copyWith(color: palette.textPrimary)),
              const SizedBox(width: 8),
              Text(_pm ? 'PM' : 'AM',
                  style: PrismType.body.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: palette.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _DialSlider(
          hour: _hour,
          onChanged: (h) => setState(() => _hour = h),
        ),
        const SizedBox(height: 6),
        // Tick labels under the track.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final t in const ['12 am', '6 am', 'Noon', '6 pm', '12 am'])
              Text(t,
                  style: PrismType.microHelper
                      .copyWith(color: palette.textTertiary)),
          ],
        ),
        const SizedBox(height: 16),
        // Quick chips.
        Row(
          children: [
            for (final (i, h) in const [7, 8, 9, 10].indexed) ...[
              if (i > 0) const SizedBox(width: 7),
              Expanded(child: _quickChip(palette, h)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _quickChip(PrismPalette palette, int h12) {
    // Chips apply within the current meridiem.
    final target = _pm ? h12 + 12 : h12;
    final on = _hour == target;
    return GestureDetector(
      onTap: () => setState(() => _hour = target),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? palette.accentSoft : palette.tile,
          border: Border.all(color: on ? palette.accent : palette.border),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text('$h12:00',
            style: PrismType.button.copyWith(
                fontSize: 12,
                color: on ? palette.accentText : palette.textSecondary)),
      ),
    );
  }
}

/// Track h6 r999 `tile2`, accent fill = hour/24, thumb 26 white with 4px
/// accent ring + shadow. Drag snaps to whole hours.
class _DialSlider extends StatelessWidget {
  const _DialSlider({required this.hour, required this.onChanged});

  final int hour;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final fraction = hour / 24;

        void handle(Offset local) {
          final h = (local.dx / w * 24).round().clamp(0, 23);
          if (h != hour) onChanged(h);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => handle(d.localPosition),
          onHorizontalDragUpdate: (d) => handle(d.localPosition),
          child: SizedBox(
            height: 26,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: palette.tile2,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Container(
                  height: 6,
                  width: w * fraction,
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Positioned(
                  left: (w * fraction - 13).clamp(0, w - 26),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.accent, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(0, 2),
                          blurRadius: 6,
                          color: Color.fromRGBO(0, 0, 0, .3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
