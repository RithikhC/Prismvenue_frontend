import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'pressable.dart';

/// Filled CTA — §3: h46 r12 (auth: h54 r999), bg `accent`, text `chipInk`
/// 14/700 (auth 16/700). Pressed = 92% scale (§6-A2); null [onTap] renders
/// disabled at 40% opacity (§6-A3).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.expanded = false,
    this.auth = false,
  });

  final String label;
  final VoidCallback? onTap;

  /// Fill the available width (sheet footers use flex sizing externally).
  final bool expanded;

  /// Sign-in variant: h54, r999, 16/700 (S00-1).
  final bool auth;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final button = Pressable(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? .4 : 1,
        child: Container(
          height: auth ? 54 : 46,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: palette.accent,
            borderRadius: BorderRadius.circular(auth ? 999 : 12),
          ),
          child: Text(
            label,
            style: PrismType.button
                .copyWith(fontSize: auth ? 16 : 14, color: palette.chipInk),
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
