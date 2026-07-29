/// Takeover of the speakers — §2 S02. Prism holds the room while staff
/// audio plays, then takes back over when the countdown ends (§6-A7:
/// extend adds the chosen duration).
class TakeoverState {
  const TakeoverState({
    required this.active,
    this.startedAt,
    this.remaining = Duration.zero,
    this.hasAutoReturn = true,
    this.startedByName,
  });

  static const inactive = TakeoverState(active: false);

  final bool active;

  /// Wall-clock start, shown in the S02-2 footer ("Started by Priya N ·
  /// 12 min ago").
  final DateTime? startedAt;

  /// Time left until Prism takes the room back. Meaningless when
  /// [hasAutoReturn] is false.
  final Duration remaining;

  /// False after S02-4's "Remove auto-return instead": Prism waits until
  /// staff hand the room back themselves, and nothing counts down.
  final bool hasAutoReturn;

  /// Who started it, for the S02-2 footer. Null when unknown (the mock
  /// before sign-in context existed, or an archived profile).
  final String? startedByName;

  TakeoverState copyWith({Duration? remaining, bool? hasAutoReturn}) =>
      TakeoverState(
        active: active,
        startedAt: startedAt,
        remaining: remaining ?? this.remaining,
        hasAutoReturn: hasAutoReturn ?? this.hasAutoReturn,
        startedByName: startedByName,
      );

  /// §6-A7 pins m:ss ("1:48") — but the S02-2/S02-4 frames show hour-scale
  /// values as h:mm ("Prism returns in 1:48" twelve minutes into a 2-hour
  /// takeover; extending 6:00 pm by 30 min reads "in 2:18"). Both are
  /// reconciled by scale: under an hour is m:ss, an hour or more is h:mm.
  String get countdownLabel => formatDuration(remaining);

  static String formatDuration(Duration d) {
    if (d.inHours >= 1) {
      final m = d.inMinutes % 60;
      return '${d.inHours}:${m.toString().padLeft(2, '0')}';
    }
    final s = d.inSeconds % 60;
    return '${d.inMinutes}:${s.toString().padLeft(2, '0')}';
  }

  /// "6:00 pm" — h:mm, lowercase meridiem, as the frames render clock times.
  static String clockLabel(DateTime t) {
    final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h12:$m ${t.hour < 12 ? 'am' : 'pm'}';
  }
}
