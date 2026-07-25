import 'dart:ui';

import '../../app/roles.dart';

/// Signed-in staff member — §2.0 top bar avatar / account menu.
class User {
  const User({
    required this.id,
    required this.name,
    required this.role,
    required this.initials,
    required this.avatarColor,
  });

  final String id;
  final String name;
  final Role role;

  /// Two-letter initials shown in the 32×32 avatar (11/800).
  final String initials;

  /// Avatar background — §2.0: PN bg #84C44A, AR bg #9A8CF0.
  final Color avatarColor;

  String get roleLabel => switch (role) {
        Role.floor => 'Floor staff',
        Role.manager => 'Manager',
        Role.owner => 'Owner',
      };
}
