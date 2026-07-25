import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'pressable.dart';
import 'prism_icons.dart';

enum ZoneStatus { ok, offline, offSchedule }

/// Zone list row — §2 S04-1: bg `surface`, r12, padding 13×15; zone name
/// 13.5/600, status sub 11 (`red` if offline / `amber` if off-schedule with
/// countdown), trailing quick-fix ("Return to Auto" 12/700 `accent`
/// text-button) or chevron.
class ZoneRow extends StatelessWidget {
  const ZoneRow({
    super.key,
    required this.name,
    required this.statusText,
    this.status = ZoneStatus.ok,
    this.quickFixLabel,
    this.onQuickFix,
    this.onTap,
  });

  final String name;
  final String statusText;
  final ZoneStatus status;

  /// e.g. "Return to Auto" (off-schedule rows).
  final String? quickFixLabel;
  final VoidCallback? onQuickFix;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final statusColor = switch (status) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style:
                          PrismType.bodySm.copyWith(color: palette.textPrimary)),
                  const SizedBox(height: 2),
                  Text(statusText,
                      style: PrismType.label.copyWith(
                          fontWeight: FontWeight.w400, color: statusColor)),
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
