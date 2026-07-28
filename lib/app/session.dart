import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/session_context.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repo.dart';

/// Signed-in user; null = signed out. The router redirects on changes.
///
/// Every screen reads this and nothing else, which is why it stayed a plain
/// `User?` when the backend landed — seventeen call sites did not have to
/// change. Token handling lives in the repository, session coordination in
/// [AuthController].
final sessionProvider =
    NotifierProvider<SessionNotifier, User?>(SessionNotifier.new);

class SessionNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void set(User? user) => state = user;
}

/// Which venue/zone this session operates on. See [SessionContext].
final sessionContextProvider =
    NotifierProvider<SessionContextNotifier, SessionContext?>(
        SessionContextNotifier.new);

class SessionContextNotifier extends Notifier<SessionContext?> {
  @override
  SessionContext? build() => null;

  void set(SessionContext? context) => state = context;
}

/// The zone every zone-scoped repository operates on.
///
/// A future zone picker sets [sessionContextProvider]; everything downstream
/// follows automatically because the repositories read this at call time
/// rather than capturing it at construction.
final currentZoneIdProvider =
    Provider<String?>((ref) => ref.watch(sessionContextProvider)?.zoneId);

final currentVenueIdProvider =
    Provider<String?>((ref) => ref.watch(sessionContextProvider)?.venueId);

/// Sign-in, sign-out and launch-time rehydration in one place.
///
/// User and context are two providers that must never disagree, so nothing
/// else is allowed to set them.
final authControllerProvider = Provider<AuthController>(AuthController.new);

class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  /// Throws [ApiException] on failure — the screen decides what to show.
  Future<void> signIn(String email, String password) async {
    final session = await _ref.read(authRepoProvider).signIn(email, password);
    _apply(session);
  }

  /// Restore from a stored token. Never throws: a failed restore just means
  /// "start signed out", which the sign-in screen already handles.
  Future<void> restore() async {
    try {
      final session = await _ref.read(authRepoProvider).restoreSession();
      if (session != null) _apply(session);
    } catch (_) {
      // Deliberately swallowed. A launch must not fail because a token could
      // not be checked; the worst case is the user signs in again.
    }
  }

  /// Clears local state immediately so the router redirects on this frame,
  /// then discards the stored token. Order matters: awaiting first would leave
  /// the signed-in UI on screen while storage is written.
  Future<void> signOut() async {
    _ref.read(sessionProvider.notifier).set(null);
    _ref.read(sessionContextProvider.notifier).set(null);
    await _ref.read(authRepoProvider).signOut();
  }

  void _apply(AuthSession session) {
    _ref.read(sessionContextProvider.notifier).set(session.context);
    // User last: the router listens to it, so context is already in place by
    // the time a redirect runs and a screen reads the current zone.
    _ref.read(sessionProvider.notifier).set(session.user);
  }
}
