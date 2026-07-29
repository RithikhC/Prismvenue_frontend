import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Bottom sheet shell — §3: sheet r20 top, bg `surface`, top border
/// `borderStrong`, padding 20×20×18, centered 38×4 r99 handle mb16, title 20
/// serif, sub 11.5; footer gap 10: Cancel flex1 / primary flex2. Sheet shadow
/// §1.7. Scrim `rgba(5,5,8,.6)` starting below the top bar.
class PrismBottomSheet extends StatelessWidget {
  const PrismBottomSheet({
    super.key,
    required this.title,
    this.sub,
    this.headerTrailing,
    required this.children,
    this.cancelLabel = 'Cancel',
    required this.primaryLabel,
    this.onCancel,
    this.onPrimary,
    this.footer,
  });

  final String title;
  final String? sub;

  /// Optional widget on the title row (S05-12's AM/PM seg).
  final Widget? headerTrailing;

  final List<Widget> children;
  final String cancelLabel;
  final String primaryLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onPrimary;

  /// Rendered BELOW the Cancel/primary row — S02-4 places "Remove
  /// auto-return instead" under "Push it back", not above it.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.borderStrong)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: PrismPalette.sheetShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: palette.borderStrong,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: PrismType.sheetTitle
                        .copyWith(color: palette.textPrimary)),
              ),
              ?headerTrailing,
            ],
          ),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!,
                style: PrismType.meta.copyWith(
                    fontSize: 11.5, color: palette.textSecondary)),
          ],
          ...children,
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(label: cancelLabel, onTap: onCancel),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: PrimaryButton(label: primaryLabel, onTap: onPrimary),
              ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Presents [sheet] as a modal with the §3 scrim `rgba(5,5,8,.6)` starting
/// BELOW the top bar (the bar stays visible and undimmed — S01-3 treatment).
/// Scrim tap dismisses with no state change (§4). Slide-up ≤200ms (§4
/// transitions note; motion undesigned — §6-B6).
Future<T?> showPrismSheet<T>(
  BuildContext context, {
  required Widget sheet,
  double topBarHeight = 0,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierColor: Colors.transparent, // scrim drawn manually below the bar
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (routeContext, animation, secondaryAnimation) {
        return Stack(
          children: [
            // Scrim below the top bar; tap dismisses.
            Positioned.fill(
              top: topBarHeight,
              child: GestureDetector(
                onTap: () => Navigator.of(routeContext).pop(),
                child: FadeTransition(
                  opacity: animation,
                  child: Container(color: const Color.fromRGBO(5, 5, 8, .6)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 1), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOut)),
                ),
                // Material ancestor for sheet content (e.g. TextFields).
                child: Material(color: Colors.transparent, child: sheet),
              ),
            ),
          ],
        );
      },
    ),
  );
}
