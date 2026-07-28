import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/session.dart';
import '../../shared/widgets/error_note.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/prism_field.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'widgets/auth_shell.dart';

/// S00-1 "Simple login — the backend lands the user in their role".
/// "Hello!" → "Sign in to get started" → Email + Password (gap 14) →
/// "Sign in" (mt22) → "Forgot Password" 13/600 (mt18, centered).
/// Pressed/loading/error states are undesigned (§6-B1).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _obscure = true;
  String? _error;
  var _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_busy) return; // a double tap must not mean two sign-in attempts
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider)
          .signIn(_email.text.trim(), _password.text);
      // The router redirect lands floor/manager on /floor, owner on /venues.
    } catch (e) {
      if (mounted) setState(() => _error = messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return AuthShell(
      heading: 'Hello!',
      helper: 'Sign in to get started',
      children: [
        PrismField(
          auth: true,
          controller: _email,
          hint: 'Email',
          leading: const Icon(LucideIcons.mail),
        ),
        const SizedBox(height: 14),
        PrismField(
          auth: true,
          controller: _password,
          hint: 'Password',
          obscure: _obscure,
          leading: const Icon(LucideIcons.lock),
          trailing: GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff),
          ),
        ),
        ErrorNote(message: _error),
        const SizedBox(height: 22),
        PrimaryButton(label: 'Sign in', auth: true, expanded: true, onTap: _signIn),
        const SizedBox(height: 18),
        AuthFooterLink(
          onTap: () => context.go('/reset/email'),
          child: Text('Forgot Password',
              style: PrismType.bodySm.copyWith(
                  fontSize: 13, color: palette.textSecondary)),
        ),
      ],
    );
  }
}
