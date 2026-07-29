import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/session.dart';
import '../mock/mock_schedule_repo.dart';
import '../models/schedule_entry.dart';

/// Schedule boundary — the Floor rail's today-view and the §2 S03 weekly
/// plan (self-drive ⇄ custom, daypart CRUD; the mock plan recurs weekly).
abstract class ScheduleRepo {
  /// Emits today's schedule immediately, then on any change.
  Stream<TodaySchedule> watchToday();

  /// S03-1 ⇄ S03-2 switch.
  Stream<ScheduleMode> watchMode();
  Future<void> setMode(ScheduleMode mode);

  /// The custom weekly plan (S03-2), all days.
  Stream<List<Daypart>> watchWeekPlan();
  Future<void> addDaypart(Daypart daypart);
  Future<void> updateDaypart(Daypart daypart);
  Future<void> deleteDaypart(String id);
}

final scheduleRepoProvider = Provider<ScheduleRepo>((ref) {
  final repo = MockScheduleRepo();
  ref.onDispose(repo.dispose);
  return repo;
});

/// Zone-scoped, so each resubscribes when sign-in establishes the zone.
final todayScheduleProvider = StreamProvider.autoDispose<TodaySchedule>((ref) {
  ref.watch(currentZoneIdProvider);
  return ref.watch(scheduleRepoProvider).watchToday();
});

final scheduleModeProvider = StreamProvider.autoDispose<ScheduleMode>((ref) {
  ref.watch(currentZoneIdProvider);
  return ref.watch(scheduleRepoProvider).watchMode();
});

final weekPlanProvider = StreamProvider.autoDispose<List<Daypart>>((ref) {
  ref.watch(currentZoneIdProvider);
  return ref.watch(scheduleRepoProvider).watchWeekPlan();
});
