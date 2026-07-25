import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/guardrails.dart';
import '../data/repositories/settings_repo.dart';
import '../shared/widgets/prism_bottom_nav.dart';
import 'roles.dart';
import 'session.dart';

/// Post-auth chrome shell: screen body + PrismBottomNav (§2.0).
/// Locked tabs per §4 role gating — floor staff see Schedule/Venues/Settings
/// locked; taps on locked tabs are inert (§6-A5).
class PrismShell extends ConsumerWidget {
  const PrismShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _tabRoutes = {
    NavTab.floor: '/floor',
    NavTab.takeover: '/takeover',
    NavTab.schedule: '/schedule',
    NavTab.venues: '/venues',
    NavTab.settings: '/settings',
  };

  NavTab _activeTab() {
    for (final entry in _tabRoutes.entries) {
      if (location == entry.value || location.startsWith('${entry.value}/')) {
        return entry.key;
      }
    }
    return NavTab.floor;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(sessionProvider)?.role;
    // S05-4 gates floor takeover: managers-only locks the Takeover tab too.
    final takeoverAccess = ref.watch(guardrailsProvider).value?.takeoverAccess ??
        TakeoverAccess.managersPlusFloor;
    final locked = role == Role.floor
        ? {
            NavTab.schedule,
            NavTab.venues,
            NavTab.settings,
            if (takeoverAccess == TakeoverAccess.managers) NavTab.takeover,
          }
        : const <NavTab>{};
    return Scaffold(
      body: child,
      bottomNavigationBar: PrismBottomNav(
        active: _activeTab(),
        lockedTabs: locked,
        onSelect: (tab) => context.go(_tabRoutes[tab]!),
      ),
    );
  }
}
