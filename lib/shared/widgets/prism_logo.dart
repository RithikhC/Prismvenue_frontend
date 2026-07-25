import 'package:flutter/material.dart';

import '../../theme/palette.dart';

/// R13 wordmark — white asset on dark, ink asset on light (§1.2).
/// Assets exported from the frames doc per the README's pointer.
class PrismLogo extends StatelessWidget {
  const PrismLogo({super.key, required this.height});

  /// 26 in the top bar, 44 on sign-in (§2.0 / S00-1).
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final dark = palette.brightness == Brightness.dark;
    return Image.asset(
      dark ? 'assets/img/r13-white.png' : 'assets/img/r13-ink.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}
