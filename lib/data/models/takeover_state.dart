/// Takeover of the speakers — §2 S02. Prism holds the room while staff
/// audio plays, then takes back over when the countdown ends (§6-A7:
/// countdown m:ss; extend adds the chosen duration).
class TakeoverState {
  const TakeoverState({
    required this.active,
    this.startedAt,
    this.remaining = Duration.zero,
  });

  static const inactive = TakeoverState(active: false);

  final bool active;

  /// Wall-clock start, shown in the S02-2 banner ("started 2:12 pm").
  final DateTime? startedAt;

  /// Time left until Prism takes the room back.
  final Duration remaining;

  TakeoverState copyWith({Duration? remaining}) => TakeoverState(
        active: active,
        startedAt: startedAt,
        remaining: remaining ?? this.remaining,
      );

  /// §6-A7 countdown format m:ss (no leading zero on minutes — "1:48").
  String get countdownLabel {
    final m = remaining.inMinutes;
    final s = remaining.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
