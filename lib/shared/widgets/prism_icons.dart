import 'package:flutter/widgets.dart';

/// Iconography — §1.8: stroke icons on a 24-grid, stroke-width 2 (2.2 for
/// chevrons/back, 2.6 for checks), round caps/joins.
///
/// Most glyphs come from `lucide_icons_flutter` (default family = 2.0 stroke,
/// matching the base spec). Chevrons and checks need non-standard strokes
/// (2.2 / 2.6) that icon fonts can't express, so those two are hand-ported
/// from the Lucide 24-grid paths as painters with exact stroke widths.

enum ChevronDirection { left, right, up, down }

/// Lucide chevron polyline, 24-grid, stroke 2.2, round caps/joins.
class PrismChevron extends StatelessWidget {
  const PrismChevron({
    super.key,
    required this.direction,
    required this.size,
    required this.color,
    this.strokeWidth = 2.2,
  });

  final ChevronDirection direction;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _PolylinePainter(
        // Lucide chevron-left: m15 18-6-6 6-6 (rotated for other directions).
        points: switch (direction) {
          ChevronDirection.left => const [Offset(15, 18), Offset(9, 12), Offset(15, 6)],
          ChevronDirection.right => const [Offset(9, 18), Offset(15, 12), Offset(9, 6)],
          ChevronDirection.up => const [Offset(6, 15), Offset(12, 9), Offset(18, 15)],
          ChevronDirection.down => const [Offset(6, 9), Offset(12, 15), Offset(18, 9)],
        },
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

/// Lucide check polyline (M20 6 9 17l-5-5), 24-grid, stroke 2.6.
class PrismCheck extends StatelessWidget {
  const PrismCheck({
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 2.6,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _PolylinePainter(
        points: const [Offset(20, 6), Offset(9, 17), Offset(4, 12)],
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _PolylinePainter extends CustomPainter {
  const _PolylinePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  static const _grid = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _grid;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      // Stroke width is specified on the 24-grid, so it scales with the glyph.
      ..strokeWidth = strokeWidth * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final path = Path()..moveTo(points.first.dx * scale, points.first.dy * scale);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx * scale, p.dy * scale);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PolylinePainter old) =>
      old.points != points || old.color != color || old.strokeWidth != strokeWidth;
}
