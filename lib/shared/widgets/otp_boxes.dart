import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// OTP entry display — §2 S00-3: 6 boxes, gap 9, square (flex-1, aspect 1),
/// r13, bg `surface`. Filled: border 1.5 `accent`, digit 24/800.
/// Next-empty: border 1.5 `borderStrong`. Other empties: border 1.5 `border`.
class OtpBoxes extends StatelessWidget {
  const OtpBoxes({super.key, this.length = 6, required this.value});

  final int length;

  /// Entered digits, e.g. "83" → first two boxes filled.
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return Row(
      children: [
        for (var i = 0; i < length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.surface,
                  border: Border.all(
                    width: 1.5,
                    color: i < value.length
                        ? palette.accent
                        : i == value.length
                            ? palette.borderStrong
                            : palette.border,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: i < value.length
                    ? Text(value[i],
                        style: PrismType.otpDigit
                            .copyWith(color: palette.textPrimary))
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
