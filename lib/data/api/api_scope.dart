import 'api_exception.dart';

/// Resolves "which zone / venue is this repository acting on?".
///
/// The Flutter repository interfaces are not zone-scoped —
/// `watchNowPlaying()`, `watchGuardrails()` and friends take no arguments —
/// while every endpoint is `/v1/zones/{id}/…`. Rather than change thirty
/// signatures and every screen that calls them, the API repositories resolve
/// the id here, at call time, from the session.
///
/// Read at call time rather than captured at construction on purpose: a future
/// zone picker only has to update the session, and every repository follows.
class ApiScope {
  const ApiScope({required this.zoneId, required this.venueId});

  final String? Function() zoneId;
  final String? Function() venueId;

  String requireZone() {
    final id = zoneId();
    if (id == null || id.isEmpty) throw _missing('zone');
    return id;
  }

  String requireVenue() {
    final id = venueId();
    if (id == null || id.isEmpty) throw _missing('venue');
    return id;
  }

  /// Reachable in one real case: a venue whose last zone was removed via S05-5.
  /// Surfacing it as a normal API error means the existing error handling shows
  /// it, rather than a null-check crashing the screen.
  ApiException _missing(String what) => ApiException(
        statusCode: 0,
        code: 'no_${what}_selected',
        message: what == 'zone'
            ? 'This venue has no zones yet.'
            : 'No venue is selected.',
      );
}
