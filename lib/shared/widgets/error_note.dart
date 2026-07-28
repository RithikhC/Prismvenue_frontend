import 'package:flutter/material.dart';

import '../../data/api/api_exception.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// PLACEHOLDER — no error state was designed (§6-B1, `open_questions.md`).
///
/// Built entirely from existing palette and type tokens so it reads as part of
/// the system rather than as new visual language, and so replacing it with the
/// designed treatment is a change in one file. It exists because the
/// alternative is worse: against a real backend, a failed sign-in or a rejected
/// guardrail change would otherwise produce no feedback whatsoever.
///
/// Two surfaces, matching the two ways things fail here:
///
/// * [ErrorNote] — inline, for a form the user is actively completing. Mirrors
///   the S00-4 match-hint row's geometry, in `red` instead of `green`.
/// * [showPrismError] — transient, for a fire-and-forget mutation that failed
///   somewhere other than the screen the user is looking at.
class ErrorNote extends StatelessWidget {
  const ErrorNote({super.key, required this.message});

  /// Null renders nothing and occupies no space, so callers can pass state
  /// directly without wrapping every use in a conditional.
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 14, color: palette.red),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message!,
              style: PrismType.meta.copyWith(
                fontWeight: FontWeight.w600,
                color: palette.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Transient failure notice for a mutation.
///
/// The message comes from the server, which writes it to be shown to venue
/// staff verbatim — we never compose our own copy from a status code.
void showPrismError(BuildContext context, Object error) {
  final palette = Theme.of(context).extension<PrismPalette>()!;
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.surface,
        elevation: 0,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.red.withValues(alpha: .45)),
        ),
        content: Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: palette.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                messageFor(error),
                style: PrismType.bodySm.copyWith(
                  fontSize: 12.5,
                  color: palette.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

/// Human-readable text for anything thrown by the data layer.
///
/// [ApiException.message] is written server-side for display. Anything else is
/// a bug on our side, and a venue manager can do nothing with its details.
String messageFor(Object error) {
  if (error is ApiException) return error.message;
  return 'Something went wrong. Try again.';
}
