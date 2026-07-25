import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_venue_repo.dart';
import '../models/venue.dart';

/// Venue/estate boundary — §2 S04. Async/stream-shaped for the future
/// backend (§C).
abstract class VenueRepo {
  /// The owner's portfolio, sorted "Needs attention" first (S04-2).
  Stream<List<Venue>> watchVenues();

  Stream<Venue?> watchVenue(String id);

  /// S04-1/2 quick-fix: puts an off-schedule zone back on auto.
  Future<void> returnZoneToAuto(String venueId, String zoneId);

  /// S04-3 "Add venue" — zones from the S04-4 sheet, by name.
  Future<void> addVenue({
    required String name,
    required String address,
    required List<String> zoneNames,
  });

  /// S05-5 "Remove zone".
  Future<void> removeZone(String zoneId);
}

final venueRepoProvider = Provider<VenueRepo>((ref) {
  final repo = MockVenueRepo();
  ref.onDispose(repo.dispose);
  return repo;
});

final venuesProvider = StreamProvider.autoDispose<List<Venue>>(
    (ref) => ref.watch(venueRepoProvider).watchVenues());

final venueProvider = StreamProvider.autoDispose.family<Venue?, String>(
    (ref, id) => ref.watch(venueRepoProvider).watchVenue(id));
