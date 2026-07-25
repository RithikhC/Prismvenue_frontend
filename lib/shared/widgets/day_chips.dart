import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// Mon–Sun chip row — §2 S05-10: 7 chips, gap 6, flex-1, padding-v 10, r10,
/// 12/700; selected = accent bg/border + `chipInk`; idle chips sit on `tile`
/// (§1.1) with a hairline border.
class DayChips extends StatelessWidget {
  const DayChips({super.key, required this.selected, this.onToggle});

  static const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Selected day indices (0 = Mon).
  final Set<int> selected;
  final ValueChanged<int>? onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: onToggle == null ? null : () => onToggle!(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected.contains(i) ? palette.accent : palette.tile,
                  border: Border.all(
                      color: selected.contains(i)
                          ? palette.accent
                          : palette.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labels[i],
                  style: PrismType.button.copyWith(
                    fontSize: 12,
                    color: selected.contains(i)
                        ? palette.chipInk
                        : palette.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
