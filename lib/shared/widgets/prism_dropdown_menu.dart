import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'prism_icons.dart';

/// Dropdown option menu — §3: bg `surface`, r12, border `borderStrong`,
/// option rows h≈40 with a trailing check on the selected row.
class PrismDropdownMenu extends StatelessWidget {
  const PrismDropdownMenu({
    super.key,
    required this.options,
    required this.selected,
    this.onSelect,
    this.width = 216,
  });

  final List<String> options;

  /// Selected index.
  final int selected;
  final ValueChanged<int>? onSelect;
  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return Container(
      width: width,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.borderStrong),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++)
            GestureDetector(
              onTap: onSelect == null ? null : () => onSelect!(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          options[i],
                          style: PrismType.bodySm.copyWith(
                            fontSize: 13,
                            color: i == selected
                                ? palette.textPrimary
                                : palette.textSecondary,
                          ),
                        ),
                      ),
                      if (i == selected)
                        PrismCheck(size: 15, color: palette.accent),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
