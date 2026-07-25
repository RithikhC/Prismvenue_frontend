import 'package:flutter/material.dart';

import '../../../shared/widgets/prism_icons.dart';
import '../../../shared/widgets/prism_logo.dart';
import '../../../theme/palette.dart';
import '../../../theme/typography.dart';

/// Shared S00 shell — §2 S00-1: full-screen `screen` bg, centered column
/// w368, logo 44h start-aligned mb22 → heading 34/700 serif → helper 15
/// `textSecondary` (mt12, mb30) → content. Sub-screens add a back button
/// 30×30 (r9, `tile`) above the heading (S00-2).
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.heading,
    this.helper,
    this.helperWidget,
    this.onBack,
    required this.children,
  });

  final String heading;

  /// Plain helper text (15, `textSecondary`).
  final String? helper;

  /// Rich helper (same slot) — S00-3 shows the email in 700 `textPrimary`.
  final Widget? helperWidget;

  /// Non-null renders the back button above the heading.
  final VoidCallback? onBack;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 368,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PrismLogo(height: 44),
                const SizedBox(height: 22),
                if (onBack != null) ...[
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: palette.tile,
                        border: Border.all(color: palette.border),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: PrismChevron(
                        direction: ChevronDirection.left,
                        size: 15,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(heading,
                    style: PrismType.displaySerif
                        .copyWith(color: palette.textPrimary)),
                if (helper != null) ...[
                  const SizedBox(height: 12),
                  Text(helper!,
                      style: PrismType.body.copyWith(
                          fontSize: 15, color: palette.textSecondary)),
                ] else if (helperWidget != null) ...[
                  const SizedBox(height: 12),
                  helperWidget!,
                ],
                const SizedBox(height: 30),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Centered footer link — S00-1 "Forgot Password": 13/600 `textSecondary`.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // Horizontal-only tap padding: symmetric-h is invisible on a centered
        // link, while vertical padding would break the spec's pinned mt18.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: child,
        ),
      ),
    );
  }
}
