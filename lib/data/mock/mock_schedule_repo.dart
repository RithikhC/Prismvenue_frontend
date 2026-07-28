import 'dart:async';

import '../models/schedule_entry.dart';
import '../repositories/schedule_repo.dart';

/// Marina Café schedule seeds. The rail's 5 rows come from the README
/// examples; the weekly plan mirrors them on every day within the S05-6
/// default open hours (7am–11pm). Exact times are seed data
/// (open_questions).
class MockScheduleRepo implements ScheduleRepo {
  static const _today = TodaySchedule(
    auto: true,
    nowIndex: 2,
    entries: [
      ScheduleEntry(timeLabel: '7:00', moodId: 'morning-calm'),
      ScheduleEntry(timeLabel: '11:00', moodId: 'daytime-flow'),
      ScheduleEntry(timeLabel: '2:00', moodId: 'afternoon-lift'),
      ScheduleEntry(timeLabel: '6:00', moodId: 'evening-warmth'),
      ScheduleEntry(timeLabel: '9:00', moodId: 'peak'),
    ],
  );

  /// (startHour, endHour, moodId) — the same blocks as before, now as real
  /// hours. Their derived labels are identical to the strings this used to
  /// hold: "7 – 11 am", "11 am – 2 pm", "2 – 6 pm", "6 – 9 pm", "9 – 11 pm".
  static const _dayTemplate = [
    (7, 11, 'morning-calm'),
    (11, 14, 'daytime-flow'),
    (14, 18, 'afternoon-lift'),
    (18, 21, 'evening-warmth'),
    (21, 23, 'peak'),
  ];

  var _mode = ScheduleMode.selfDrive; // S03-1 is the entry frame
  late final List<Daypart> _plan = [
    for (var day = 0; day < 7; day++)
      for (final (i, (start, end, moodId)) in _dayTemplate.indexed)
        Daypart(
          id: 'd$day-$i',
          dayIndex: day,
          startHour: start,
          endHour: end,
          moodId: moodId,
        ),
  ];
  var _nextId = 0;

  final _todayController = StreamController<TodaySchedule>.broadcast();
  final _modeController = StreamController<ScheduleMode>.broadcast();
  final _planController = StreamController<List<Daypart>>.broadcast();

  @override
  Stream<TodaySchedule> watchToday() async* {
    yield _today;
    yield* _todayController.stream;
  }

  @override
  Stream<ScheduleMode> watchMode() async* {
    yield _mode;
    yield* _modeController.stream;
  }

  @override
  Future<void> setMode(ScheduleMode mode) async {
    _mode = mode;
    _modeController.add(mode);
  }

  @override
  Stream<List<Daypart>> watchWeekPlan() async* {
    yield List.unmodifiable(_plan);
    yield* _planController.stream;
  }

  void _emitPlan() => _planController.add(List.unmodifiable(_plan));

  @override
  Future<void> addDaypart(Daypart daypart) async {
    _plan.add(Daypart(
      id: 'new-${_nextId++}',
      dayIndex: daypart.dayIndex,
      startHour: daypart.startHour,
      endHour: daypart.endHour,
      moodId: daypart.moodId,
    ));
    _emitPlan();
  }

  @override
  Future<void> updateDaypart(Daypart daypart) async {
    final i = _plan.indexWhere((d) => d.id == daypart.id);
    if (i != -1) _plan[i] = daypart;
    _emitPlan();
  }

  @override
  Future<void> deleteDaypart(String id) async {
    _plan.removeWhere((d) => d.id == id);
    _emitPlan();
  }

  void dispose() {
    _todayController.close();
    _modeController.close();
    _planController.close();
  }
}
