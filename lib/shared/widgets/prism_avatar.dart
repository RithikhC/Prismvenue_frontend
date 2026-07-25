import 'package:flutter/widgets.dart';

import '../../theme/typography.dart';

/// Initials avatar — §2.0: 32×32 circle, initials 11/800 (PN bg #84C44A,
/// AR bg #9A8CF0); account-menu header uses a 38 avatar. Font scales with
/// size (11 at 32).
class PrismAvatar extends StatelessWidget {
  const PrismAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 32,
    this.textColor = const Color(0xFF16120E),
  });

  final String initials;
  final Color color;
  final double size;

  /// §2.0 note: "floor/manager-dark-ink" — ink text on the colored disc.
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initials,
        style: PrismType.micro.copyWith(
          fontSize: 11 * size / 32,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}
