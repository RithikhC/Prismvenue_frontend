import 'package:flutter/material.dart';

import '../../../shared/widgets/mood_tile.dart';
import '../../../theme/moods.dart';
import '../../../theme/palette.dart';
import '../../../theme/typography.dart';

/// Moods block — §2 S01-1: header row mb11 ("Moods" 19 serif + "Tap to
/// change the vibe · one tap" 11 `textSecondary`), grid 3×2, gap 12,
/// tile h124.
class MoodGrid extends StatelessWidget {
  const MoodGrid({
    super.key,
    required this.currentMoodId,
    required this.paused,
    this.onMoodTap,
  });

  final String currentMoodId;
  final bool paused;
  final ValueChanged<Mood>? onMoodTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;

    MoodTileState stateFor(Mood mood) {
      if (mood.id != currentMoodId) return MoodTileState.idle;
      return paused ? MoodTileState.paused : MoodTileState.playing;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Moods',
                style:
                    PrismType.sectionH2.copyWith(color: palette.textPrimary)),
            const Spacer(),
            Text('Tap to change the vibe · one tap',
                style: PrismType.label.copyWith(
                    fontWeight: FontWeight.w400,
                    color: palette.textSecondary)),
          ],
        ),
        const SizedBox(height: 11),
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: 12),
          Row(
            children: [
              for (var col = 0; col < 3; col++) ...[
                if (col > 0) const SizedBox(width: 12),
                Expanded(
                  child: Builder(builder: (context) {
                    final mood = moods[row * 3 + col];
                    return MoodTile(
                      mood: mood,
                      state: stateFor(mood),
                      meta: '${mood.bpm} BPM',
                      onTap: onMoodTap == null ? null : () => onMoodTap!(mood),
                    );
                  }),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
