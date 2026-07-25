import 'package:flutter/material.dart';

import '../../theme/palette.dart';

/// Energy indicator on mood tiles — §3: 5 bars 3×10 r2 gap2;
/// filled = mood color, rest `unfilled`.
class EnergyBars extends StatelessWidget {
  const EnergyBars({super.key, required this.energy, required this.color});

  /// 1–5.
  final int energy;

  /// Mood color for the filled bars.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Container(
            width: 3,
            height: 10,
            decoration: BoxDecoration(
              color: i < energy ? color : palette.unfilled,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    );
  }
}
