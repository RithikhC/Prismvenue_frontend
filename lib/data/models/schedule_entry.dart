/// One row of the Floor schedule rail — §2 S01-1.
class ScheduleEntry {
  const ScheduleEntry({required this.timeLabel, required this.moodId});

  /// Short time label, e.g. "7:00" (rail column is w34 at 11/700).
  final String timeLabel;

  /// References the fixed 6-mood set (theme/moods.dart).
  final String moodId;
}

/// §2 S03-1/2: Prism either self-drives or follows the custom weekly plan.
enum ScheduleMode { selfDrive, custom }

/// One block of the custom weekly plan — §2 S03-2 row: time range 11/700 +
/// mood dot + name. Times are display labels; how they're edited is not
/// designed (open_questions).
class Daypart {
  const Daypart({
    required this.id,
    required this.dayIndex,
    required this.rangeLabel,
    required this.moodId,
  });

  final String id;

  /// 0 = Monday … 6 = Sunday.
  final int dayIndex;

  /// e.g. "7 – 11 am".
  final String rangeLabel;

  final String moodId;

  Daypart copyWith({int? dayIndex, String? rangeLabel, String? moodId}) =>
      Daypart(
        id: id,
        dayIndex: dayIndex ?? this.dayIndex,
        rangeLabel: rangeLabel ?? this.rangeLabel,
        moodId: moodId ?? this.moodId,
      );
}

/// Today's schedule as the Floor rail consumes it — S01-1: 5 rows, the
/// current one highlighted, "Auto" chip in the header.
class TodaySchedule {
  const TodaySchedule({
    required this.entries,
    required this.nowIndex,
    required this.auto,
  });

  final List<ScheduleEntry> entries;
  final int nowIndex;

  /// Rail header chip ("Auto") — Prism driving on schedule.
  final bool auto;
}
