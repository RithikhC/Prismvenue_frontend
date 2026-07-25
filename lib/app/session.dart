import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user.dart';

/// Signed-in user; null = signed out. The router redirects on changes.
/// Phase 3 moves sign-in/out through AuthRepo; the state shape stays.
final sessionProvider =
    NotifierProvider<SessionNotifier, User?>(SessionNotifier.new);

class SessionNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void signIn(User user) => state = user;

  void signOut() => state = null;
}
