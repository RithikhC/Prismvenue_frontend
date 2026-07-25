/// What the room is playing right now — Floor hero (§2 S01-1/S01-2).
class PlaybackState {
  const PlaybackState({
    required this.moodId,
    required this.paused,
    this.pausedBy,
    required this.contextLine,
  });

  /// References the fixed 6-mood set (theme/moods.dart).
  final String moodId;

  /// S01-2: room paused by staff; hero shows play icon, tile eq freezes.
  final bool paused;

  /// First name shown in the paused pill ("Paused by Priya · …").
  final String? pausedBy;

  /// Hero context line, e.g. "mid-afternoon · ~60% full · clear".
  final String contextLine;

  PlaybackState copyWith({
    String? moodId,
    bool? paused,
    String? pausedBy,
    String? contextLine,
  }) {
    return PlaybackState(
      moodId: moodId ?? this.moodId,
      paused: paused ?? this.paused,
      pausedBy: paused == false ? null : (pausedBy ?? this.pausedBy),
      contextLine: contextLine ?? this.contextLine,
    );
  }
}
