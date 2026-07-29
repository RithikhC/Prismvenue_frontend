import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/session.dart';
import '../mock/mock_settings_repo.dart';
import '../models/guardrails.dart';

/// Guardrails & settings boundary — §2 S05. Async/stream-shaped (§C).
abstract class SettingsRepo {
  Stream<Guardrails> watchGuardrails();
  Future<void> updateGuardrails(Guardrails next);

  Stream<OpenHours> watchOpenHours();
  Future<void> setEverydayHours({required int openHour, required int closeHour});
  Future<void> addException(HoursException exception);
}

final settingsRepoProvider = Provider<SettingsRepo>((ref) {
  final repo = MockSettingsRepo();
  ref.onDispose(repo.dispose);
  return repo;
});

/// Watching the current zone/venue is what makes these resubscribe once
/// sign-in establishes them. Without it, a provider subscribed before sign-in
/// (the router listens to guardrails at startup for the S05-4 takeover gate)
/// fetches with no zone, fails, and has nothing to tell it to try again — so
/// every settings screen renders fallback defaults for the whole session.
final guardrailsProvider = StreamProvider.autoDispose<Guardrails>((ref) {
  ref.watch(currentZoneIdProvider);
  return ref.watch(settingsRepoProvider).watchGuardrails();
});

final openHoursProvider = StreamProvider.autoDispose<OpenHours>((ref) {
  ref.watch(currentVenueIdProvider);
  return ref.watch(settingsRepoProvider).watchOpenHours();
});
