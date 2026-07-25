import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'pressable.dart';
import 'prism_icons.dart';
import 'zone_row.dart' show ZoneStatus;

/// Portfolio venue row — §2 S04-2: 32 initial-avatar, name 13.5/700, sub
/// "1 zone · Peak" 11; problem rows carry red/amber status + "Return to
/// Auto"; healthy rows stay quiet (no % values). Row tap drills into the
/// venue.
class VenueRow extends StatelessWidget {
  const VenueRow({
    super.key,
    required this.name,
    required this.sub,
    this.status = ZoneStatus.ok,
    this.quickFixLabel,
    this.onQuickFix,
    this.onTap,
  });

  final String name;
  final String sub;
  final ZoneStatus status;
  final String? quickFixLabel;
  final VoidCallback? onQuickFix;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final subColor = switch (status) {
      ZoneStatus.ok => palette.textSecondary,
      ZoneStatus.offline => palette.red,
      ZoneStatus.offSchedule => palette.amber,
    };
    // §6-A2: `tile2` flash while pressed.
    return Pressable(
      onTap: onTap,
      effect: PressEffect.flash,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(color: palette.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Text(name.isEmpty ? '?' : name[0],
                  style: PrismType.micro.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: palette.accentText)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: PrismType.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: PrismType.label.copyWith(
                          fontWeight: FontWeight.w400, color: subColor)),
                ],
              ),
            ),
            if (quickFixLabel != null)
              GestureDetector(
                onTap: onQuickFix,
                child: Text(quickFixLabel!,
                    style: PrismType.button
                        .copyWith(fontSize: 12, color: palette.accent)),
              )
            else
              PrismChevron(
                direction: ChevronDirection.right,
                size: 15,
                color: palette.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
