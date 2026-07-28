import '../models/schedule_entry.dart';
import '../repositories/schedule_repo.dart';
import 'api_client.dart';
import 'api_scope.dart';
import 'watchable.dart';

/// `ScheduleRepo` against the real API.
///
/// `TodaySchedule.nowIndex` is taken from the server, never computed here: it
/// depends on the current time in the *venue's* timezone, which the client does
/// not know. A device in another timezone would otherwise highlight the wrong
/// row on the Floor rail.
class ApiScheduleRepo implements ScheduleRepo {
  ApiScheduleRepo(this._client, this._scope);

  final ApiClient _client;
  final ApiScope _scope;

  late final _today = Watchable<TodaySchedule>(
    _fetchToday,
    scopeKey: _scope.zoneId,
  );
  late final _mode = Watchable<ScheduleMode>(
    _fetchMode,
    scopeKey: _scope.zoneId,
  );
  late final _plan = Watchable<List<Daypart>>(
    _fetchPlan,
    scopeKey: _scope.zoneId,
  );

  @override
  Stream<TodaySchedule> watchToday() => _today.watch();

  @override
  Stream<ScheduleMode> watchMode() => _mode.watch();

  @override
  Future<void> setMode(ScheduleMode mode) async {
    await _client.post(
      '/zones/${_scope.requireZone()}/mode',
      body: {'mode': mode == ScheduleMode.selfDrive ? 'self_drive' : 'custom'},
    );
    await _mode.refresh();
    // Switching between self-drive and a custom plan changes what the Floor
    // rail should show, so today has to come along.
    await _today.refresh();
  }

  @override
  Stream<List<Daypart>> watchWeekPlan() => _plan.watch();

  @override
  Future<void> addDaypart(Daypart daypart) async {
    // The client's `id` is ignored — the server assigns the real one, which is
    // why the sheet can construct a Daypart with an empty id.
    await _client.post(
      '/zones/${_scope.requireZone()}/dayparts',
      body: _daypartToJson(daypart),
    );
    await _refreshPlan();
  }

  @override
  Future<void> updateDaypart(Daypart daypart) async {
    await _client.patch('/dayparts/${daypart.id}', body: _daypartToJson(daypart));
    await _refreshPlan();
  }

  @override
  Future<void> deleteDaypart(String id) async {
    await _client.delete('/dayparts/$id');
    await _refreshPlan();
  }

  /// Any plan change can move the "NOW" row, so both streams refresh together.
  Future<void> _refreshPlan() async {
    await _plan.refresh();
    await _today.refresh();
  }

  Future<TodaySchedule> _fetchToday() async {
    final json = await _client.get('/zones/${_scope.requireZone()}/today')
        as Map<String, dynamic>;
    return TodaySchedule(
      entries: [
        for (final raw in (json['entries'] as List? ?? const []))
          ScheduleEntry(
            timeLabel: (raw as Map)['time_label'] as String? ?? '',
            moodId: raw['mood_id'] as String? ?? 'daytime-flow',
          ),
      ],
      nowIndex: json['now_index'] as int? ?? 0,
      auto: json['auto'] as bool? ?? true,
    );
  }

  Future<ScheduleMode> _fetchMode() async {
    final json = await _client.get('/zones/${_scope.requireZone()}/mode')
        as Map<String, dynamic>;
    return json['mode'] == 'custom' ? ScheduleMode.custom : ScheduleMode.selfDrive;
  }

  Future<List<Daypart>> _fetchPlan() async {
    final json =
        await _client.get('/zones/${_scope.requireZone()}/dayparts') as List;
    return [
      for (final raw in json)
        _daypartFrom((raw as Map).cast<String, dynamic>()),
    ];
  }

  static Daypart _daypartFrom(Map<String, dynamic> json) => Daypart(
        id: json['id'] as String,
        dayIndex: json['day_index'] as int? ?? 0,
        startHour: json['start_hour'] as int? ?? 0,
        endHour: json['end_hour'] as int? ?? 0,
        moodId: json['mood_id'] as String? ?? 'daytime-flow',
        // Prefer the server's label so the two can never disagree about how a
        // range reads; Daypart derives its own if it is absent.
        serverRangeLabel: json['range_label'] as String?,
      );

  /// `range_label` is deliberately not sent — it is derived from the hours
  /// server-side, so sending it would invite the two to drift apart.
  static Map<String, dynamic> _daypartToJson(Daypart d) => {
        'day_index': d.dayIndex,
        'start_hour': d.startHour,
        'end_hour': d.endHour,
        'mood_id': d.moodId,
      };

  void dispose() {
    _today.dispose();
    _mode.dispose();
    _plan.dispose();
  }
}
