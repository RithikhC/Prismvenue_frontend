import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'pressable.dart';

/// Quiet counterpart to PrimaryButton — §3: h46 r12, bg `tile`, 1px `border`,
/// text `textSecondary` 14/700. Pressed = 92% scale (§6-A2); null [onTap]
/// renders disabled at 40% opacity (§6-A3).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.expanded = false,
  });

  final String label;

  /// Optional leading glyph (S02-2's "Running long? Extend" carries the
  /// clock icon). Sized/coloured by the caller.
  final Widget? icon;

  final VoidCallback? onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final button = Pressable(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? .4 : 1,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: palette.tile,
            border: Border.all(color: palette.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              // Flexible so long labels wrap as they did before the icon slot.
              Flexible(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: PrismType.button
                        .copyWith(color: palette.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
