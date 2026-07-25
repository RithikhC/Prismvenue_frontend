import 'dart:ui';

import '../../app/roles.dart';
import '../models/user.dart';

/// Marina Café seed data used across mock repositories — values from the
/// README's examples (§2.0 avatars: PN bg #84C44A floor/manager, AR bg
/// #9A8CF0 owner; "Paused by Priya" S01-2).
class Seed {
  Seed._();

  static const venueName = 'Marina Café';
  static const venueStatus = 'Main floor · online';

  /// The single venue the manager operates (S04-1 is their /venues).
  static const managerVenueId = 'marina-cafe';

  static const floorUser = User(
    id: 'u-priya',
    name: 'Priya Nair',
    role: Role.floor,
    initials: 'PN',
    avatarColor: Color(0xFF84C44A),
  );

  static const managerUser = User(
    id: 'u-priya-mgr',
    name: 'Priya Nair',
    role: Role.manager,
    initials: 'PN',
    avatarColor: Color(0xFF84C44A),
  );

  /// "AR" initials/color per §2.0; full name is mock seed (not in README).
  static const ownerUser = User(
    id: 'u-arjun',
    name: 'Arjun Rao',
    role: Role.owner,
    initials: 'AR',
    avatarColor: Color(0xFF9A8CF0),
  );

  static User userFor(Role role) => switch (role) {
        Role.floor => floorUser,
        Role.manager => managerUser,
        Role.owner => ownerUser,
      };
}
