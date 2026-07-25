import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final guardrailsProvider = StreamProvider.autoDispose<Guardrails>(
    (ref) => ref.watch(settingsRepoProvider).watchGuardrails());

final openHoursProvider = StreamProvider.autoDispose<OpenHours>(
    (ref) => ref.watch(settingsRepoProvider).watchOpenHours());
