import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/prism_top_bar.dart';
import '../../theme/moods.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// S02-3 "Confirm before returning to Prism — no accidental handbacks".
/// ConfirmDialog over dimmed S02-2: rotate-ccw in the accentSoft 44 r12
/// well; "Return to Prism now?"; body resumes the current mood in bold;
/// Cancel / "Return to Prism". Resolves true when confirmed.
Future<bool?> showConfirmReturnDialog(BuildContext context,
    {required Mood currentMood}) {
  final palette = Theme.of(context).extension<PrismPalette>()!;
  return showPrismDialog<bool>(
    context,
    topBarHeight: PrismTopBar.height,
    dialog: Builder(
      builder: (dialogContext) => ConfirmDialog(
        icon: Icon(LucideIcons.rotateCcw, size: 20, color: palette.accentText),
        title: 'Return to Prism now?',
        body: TextSpan(
          text: 'Prism takes the room back and resumes ',
          children: [
            TextSpan(
                text: currentMood.name,
                style: PrismType.dialogBody.copyWith(
                    fontWeight: FontWeight.w700, color: palette.textPrimary)),
            const TextSpan(
                text: '. Your own audio will stop playing on the speakers.'),
          ],
        ),
        confirmLabel: 'Return to Prism',
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    ),
  );
}
