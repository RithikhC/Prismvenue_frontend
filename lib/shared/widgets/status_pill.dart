import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';

enum PillTone { accent, amber, green }

/// Small status pill — §3: r999, padding 3–5 × 9–11, 10–11/700, tone@16% bg.
/// Hero example (S01-1): "Prism is driving" — accentSoft bg, 5px dot,
/// padding 3×9, text 10/700.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.text,
    this.span,
    this.tone = PillTone.accent,
    this.dot = false,
    this.padding = const EdgeInsets.symmetric(vertical: 3, horizontal: 9),
    this.fontSize = 10,
  });

  final String text;

  /// Rich override for [text] — S01-2's pill bolds the name
  /// ("Paused by **Priya** · tap play to resume").
  final InlineSpan? span;

  final PillTone tone;

  /// 5px leading dot (hero pill).
  final bool dot;

  /// §3 range: 3–5 vertical × 9–11 horizontal.
  final EdgeInsets padding;

  /// §3 range: 10–11.
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    // accent tone uses the accentSoft/accentText token pair (§1.1);
    // amber/green take tone@16% bg with the tone itself as text.
    final (bg, fg) = switch (tone) {
      PillTone.accent => (palette.accentSoft, palette.accentText),
      PillTone.amber => (palette.amber.withValues(alpha: .16), palette.amber),
      PillTone.green => (palette.green.withValues(alpha: .16), palette.green),
    };
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: span != null
                ? Text.rich(span!,
                    style: PrismType.micro
                        .copyWith(fontSize: fontSize, color: fg))
                : Text(text,
                    style: PrismType.micro
                        .copyWith(fontSize: fontSize, color: fg)),
          ),
        ],
      ),
    );
  }
}
