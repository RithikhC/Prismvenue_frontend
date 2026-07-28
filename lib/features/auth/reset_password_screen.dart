import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/auth_repo.dart';
import '../../shared/widgets/error_note.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/prism_field.dart';
import '../../shared/widgets/prism_icons.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'reset_email_screen.dart';
import 'widgets/auth_shell.dart';

/// S00-4 "New password — enter and confirm". Two labelled password fields
/// ("New password" accent border / "Confirm password" `borderStrong`),
/// match-hint row mt12 (14 check + "At least 8 characters · both match"
/// 11.5/600 `green` — shown as in the frame; validation is undesigned,
/// §6-B9), then "Save new password" → back to S00-1.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _error;

  Future<void> _save() async {
    final email = ref.read(resetEmailProvider);
    final resetToken = ref.read(resetTokenProvider);
    if (resetToken == null) {
      // Reachable by navigating straight to /reset/new — the router treats all
      // /reset/* paths as public. Without the token the server would refuse
      // anyway; failing here says why instead of showing a generic error.
      setState(() => _error = 'Verify the emailed code first.');
      return;
    }
    setState(() => _error = null);
    try {
      await ref.read(authRepoProvider).saveNewPassword(
            email: email,
            password: _password.text,
            resetToken: resetToken,
          );
    } catch (e) {
      if (mounted) setState(() => _error = messageFor(e));
      return;
    }
    // Single-use: drop it so a stale token cannot be replayed.
    ref.read(resetTokenProvider.notifier).set(null);
    if (!mounted) return;
    context.go('/signin');
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return AuthShell(
      heading: 'Set a new password',
      onBack: () => context.go('/reset/code'),
      children: [
        PrismField(
          auth: true,
          label: 'New password',
          controller: _password,
          obscure: true,
          focusedOverride: true,
        ),
        const SizedBox(height: 14),
        PrismField(
          auth: true,
          label: 'Confirm password',
          controller: _confirm,
          obscure: true,
          strongBorder: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            PrismCheck(size: 14, color: palette.green),
            const SizedBox(width: 6),
            Flexible(
              child: Text('At least 8 characters · both match',
                  style: PrismType.meta.copyWith(
                      fontWeight: FontWeight.w600, color: palette.green)),
            ),
          ],
        ),
        ErrorNote(message: _error),
        const SizedBox(height: 22),
        PrimaryButton(
            label: 'Save new password', auth: true, expanded: true, onTap: _save),
      ],
    );
  }
}
