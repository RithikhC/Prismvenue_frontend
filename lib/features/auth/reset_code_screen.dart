import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/auth_repo.dart';
import '../../shared/widgets/otp_boxes.dart';
import '../../shared/widgets/primary_button.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'reset_email_screen.dart';
import 'widgets/auth_shell.dart';

/// S00-3 "Enter code — 6-digit code from the email". Helper shows the email
/// in 700 `textPrimary`; OTP row per §2 S00-3; "Didn't get it? Resend code"
/// with the link part in accent. Wrong-code state is undesigned (§6-B1);
/// helper copy around the email is assumed (see open_questions.md).
class ResetCodeScreen extends ConsumerStatefulWidget {
  const ResetCodeScreen({super.key});

  @override
  ConsumerState<ResetCodeScreen> createState() => _ResetCodeScreenState();
}

class _ResetCodeScreenState extends ConsumerState<ResetCodeScreen> {
  final _code = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final email = ref.read(resetEmailProvider);
    await ref.read(authRepoProvider).verifyResetCode(email, _code.text);
    if (!mounted) return;
    context.go('/reset/new');
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final email = ref.watch(resetEmailProvider);
    return AuthShell(
      heading: 'Enter the code',
      onBack: () => context.go('/reset/email'),
      helperWidget: Text.rich(
        TextSpan(
          text: 'Enter the 6-digit code we sent to ',
          children: [
            TextSpan(
                text: email,
                style: PrismType.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary)),
            const TextSpan(text: '.'),
          ],
        ),
        style:
            PrismType.body.copyWith(fontSize: 15, color: palette.textSecondary),
      ),
      children: [
        // OTP row — taps focus a hidden digits-only field.
        GestureDetector(
          onTap: () => _focus.requestFocus(),
          child: Stack(
            children: [
              Offstage(
                child: SizedBox(
                  width: 1,
                  height: 1,
                  child: TextField(
                    controller: _code,
                    focusNode: _focus,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              OtpBoxes(value: _code.text),
            ],
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(label: 'Verify', auth: true, expanded: true, onTap: _verify),
        const SizedBox(height: 18),
        AuthFooterLink(
          onTap: () =>
              ref.read(authRepoProvider).sendResetCode(email),
          child: Text.rich(
            TextSpan(
              text: "Didn't get it? ",
              children: [
                TextSpan(
                    text: 'Resend code',
                    style: PrismType.bodySm.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.accent)),
              ],
            ),
            style: PrismType.bodySm
                .copyWith(fontSize: 13, color: palette.textSecondary),
          ),
        ),
      ],
    );
  }
}
