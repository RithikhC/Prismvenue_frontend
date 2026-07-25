import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// Segmented toggle — §3: container bg `tile`, 1px `border`, r999 (pill) /
/// r11 (boxed), padding 3–4; items 11–12/700; selected bg `accent` `chipInk`.
///
/// Pill items hug content (top bar Dark/Light: 5×12; AM/PM dial: 6×14);
/// boxed items flex to fill (S02-1 durations: flex-1, padding-v 8, r8).
class SegToggle extends StatelessWidget {
  const SegToggle({
    super.key,
    required this.options,
    required this.selected,
    this.onChanged,
    this.pill = false,
    this.itemPadding,
    this.fontSize,
  });

  final List<String> options;

  /// Selected index.
  final int selected;
  final ValueChanged<int>? onChanged;

  /// Pill (r999) vs boxed (r11) container.
  final bool pill;

  /// Override per use: pill defaults 5×12, boxed defaults 8 vertical.
  final EdgeInsets? itemPadding;

  /// §3 range 11–12; pill defaults 11, boxed 11.5 (S02-1).
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final size = fontSize ?? (pill ? 11 : 11.5);
    final padding = itemPadding ??
        (pill
            ? const EdgeInsets.symmetric(vertical: 5, horizontal: 12)
            : const EdgeInsets.symmetric(vertical: 8));

    Widget item(int i) {
      final on = i == selected;
      final child = GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(i),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: padding,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? palette.accent : null,
            borderRadius: BorderRadius.circular(pill ? 999 : 8),
          ),
          child: Text(
            options[i],
            style: PrismType.button.copyWith(
              fontSize: size,
              color: on ? palette.chipInk : palette.textSecondary,
            ),
          ),
        ),
      );
      return pill ? child : Expanded(child: child);
    }

    return Container(
      padding: EdgeInsets.all(pill ? 3 : 4),
      decoration: BoxDecoration(
        color: palette.tile,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(pill ? 999 : 11),
      ),
      child: Row(
        mainAxisSize: pill ? MainAxisSize.min : MainAxisSize.max,
        children: [for (var i = 0; i < options.length; i++) item(i)],
      ),
    );
  }
}
