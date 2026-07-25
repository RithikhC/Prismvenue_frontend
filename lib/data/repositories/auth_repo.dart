import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_auth_repo.dart';
import '../models/user.dart';

/// Auth boundary — front-end only (§Target): async so the eventual FastAPI
/// backend slots in behind the same interface.
abstract class AuthRepo {
  /// S00-1: "the backend lands the user in their role".
  Future<User> signIn(String email, String password);

  /// S00-2: email a 6-digit verification code.
  Future<void> sendResetCode(String email);

  /// S00-3: verify the entered code.
  Future<void> verifyResetCode(String email, String code);

  /// S00-4: set the new password, then back to sign-in.
  Future<void> saveNewPassword(String email, String password);
}

final authRepoProvider = Provider<AuthRepo>((ref) => MockAuthRepo());
