import 'package:flutter/material.dart';

import '../../theme/moods.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'energy_bars.dart';
import 'eq_bars.dart';

enum MoodTileState { idle, playing, paused }

/// Mood tile — §3: h124 r16 padding 13×15 (v×h).
/// Idle: `tint` base + mood tint gradient (13%→3%), border mood@22%,
///       11px dot + EnergyBars; name 19 italic serif bottom-anchored,
///       meta 11.5.
/// Playing: mood gradient pair (150°), white text, EqBars + "Playing" chip
///          (white@25% bg), shadow 0 12 28 mood@28% (§1.7).
/// Paused: playing visuals with the eq animation stopped (S01-2 — the spec's
///         only stated delta; chip copy unverified, see open_questions.md).
class MoodTile extends StatelessWidget {
  const MoodTile({
    super.key,
    required this.mood,
    this.state = MoodTileState.idle,
    this.meta,
    this.onTap,
  });

  final Mood mood;
  final MoodTileState state;

  /// Meta line under the name (11.5). Content is screen-supplied.
  final String? meta;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final b = palette.brightness;
    final playing = state != MoodTileState.idle;
    const white = Color(0xFFFFFFFF);

    final fg = playing ? white : palette.textPrimary;
    final metaFg = playing ? white : palette.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 124,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
        decoration: playing
            ? BoxDecoration(
                gradient: mood.playingGradient(),
                borderRadius: BorderRadius.circular(16),
                boxShadow: PrismPalette.playingTileShadow(mood.dot(b)),
              )
            : BoxDecoration(
                // §1.3 tint gradient pre-composited over the `tint` base.
                gradient: mood.idleTintGradient(b, over: palette.tint),
                border: Border.all(color: mood.idleBorder(b)),
                borderRadius: BorderRadius.circular(16),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (playing) ...[
                  EqBars(color: white, animate: state == MoodTileState.playing),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 9),
                    decoration: BoxDecoration(
                      color: white.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('Playing',
                        style: PrismType.micro.copyWith(color: white)),
                  ),
                ] else ...[
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                        color: mood.dot(b), shape: BoxShape.circle),
                  ),
                  const Spacer(),
                  EnergyBars(energy: mood.energy, color: mood.dot(b)),
                ],
              ],
            ),
            const Spacer(),
            Text(mood.name, style: PrismType.moodNameTile.copyWith(color: fg)),
            if (meta != null)
              Text(meta!, style: PrismType.meta.copyWith(color: metaFg)),
          ],
        ),
      ),
    );
  }
}
