import '../models/user.dart';
import '../repositories/auth_repo.dart';
import 'seed.dart';

/// In-memory auth. Any credentials succeed (failed sign-in is undesigned,
/// §6-B1). The role the "backend" lands the user in is mocked off the email
/// so all three journeys are reachable from the real sign-in screen:
/// *floor*@… → floor staff, *owner*/*arjun*@… → owner, anything else →
/// manager (Priya — "you're a manager", S05-1).
class MockAuthRepo implements AuthRepo {
  /// Zero: loading states are undesigned (§6-B1), so the mock resolves
  /// instantly; the real backend replaces this behind the same interface.
  static const _latency = Duration.zero;

  @override
  Future<User> signIn(String email, String password) async {
    await Future<void>.delayed(_latency);
    final e = email.toLowerCase();
    if (e.contains('floor')) return Seed.floorUser;
    if (e.contains('owner') || e.contains('arjun')) return Seed.ownerUser;
    return Seed.managerUser;
  }

  @override
  Future<void> sendResetCode(String email) => Future.delayed(_latency);

  @override
  Future<void> verifyResetCode(String email, String code) =>
      Future.delayed(_latency);

  @override
  Future<void> saveNewPassword(String email, String password) =>
      Future.delayed(_latency);
}
