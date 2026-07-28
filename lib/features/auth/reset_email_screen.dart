import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repositories/auth_repo.dart';
import '../../shared/widgets/error_note.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/prism_field.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'widgets/auth_shell.dart';

/// The email the reset flow is acting on — shown bold on S00-3. Seeded with
/// the frame's value (S00-2 shows the field filled with priya@marinacafe.com).
final resetEmailProvider =
    NotifierProvider<ResetEmailNotifier, String>(ResetEmailNotifier.new);

class ResetEmailNotifier extends Notifier<String> {
  @override
  String build() => 'priya@marinacafe.com';

  void set(String email) => state = email;
}

/// Proof that the emailed code was verified, carried from S00-3 to S00-4.
///
/// The reset cannot complete without it: `saveNewPassword` requires it, and
/// the server refuses without it. As originally specified, save-password took
/// only `{email, password}`, which let anyone set anyone's password —
/// INTEGRATION_PLAN.md §5.1. Held in memory only, for one flow, deliberately
/// never persisted.
final resetTokenProvider =
    NotifierProvider<ResetTokenNotifier, String?>(ResetTokenNotifier.new);

class ResetTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? token) => state = token;
}

/// S00-2 "Forgot password — email a verification code".
class ResetEmailScreen extends ConsumerStatefulWidget {
  const ResetEmailScreen({super.key});

  @override
  ConsumerState<ResetEmailScreen> createState() => _ResetEmailScreenState();
}

class _ResetEmailScreenState extends ConsumerState<ResetEmailScreen> {
  late final _email =
      TextEditingController(text: ref.read(resetEmailProvider));

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  String? _error;

  Future<void> _send() async {
    final email = _email.text.trim();
    ref.read(resetEmailProvider.notifier).set(email);
    setState(() => _error = null);
    try {
      await ref.read(authRepoProvider).sendResetCode(email);
    } catch (e) {
      if (mounted) setState(() => _error = messageFor(e));
      return;
    }
    if (!mounted) return;
    // Always advances on success, even for an unknown address — the server
    // deliberately does not reveal whether the account exists.
    context.go('/reset/code');
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return AuthShell(
      heading: 'Reset your password',
      helper:
          "Enter your email and we'll send you a 6-digit verification code.",
      onBack: () => context.go('/signin'),
      children: [
        // Frame shows the field filled, accent border.
        PrismField(
          auth: true,
          controller: _email,
          focusedOverride: true,
          leading: const Icon(LucideIcons.mail),
        ),
        ErrorNote(message: _error),
        const SizedBox(height: 22),
        PrimaryButton(
            label: 'Send verification code',
            auth: true,
            expanded: true,
            onTap: _send),
        const SizedBox(height: 18),
        AuthFooterLink(
          onTap: () => context.go('/signin'),
          child: Text('Back to sign in',
              style: PrismType.bodySm.copyWith(
                  fontSize: 13, color: palette.textSecondary)),
        ),
      ],
    );
  }
}
