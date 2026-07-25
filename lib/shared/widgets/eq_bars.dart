import 'package:flutter/widgets.dart';

/// Equalizer animation on the playing tile — §3 EqBars: 4 bars 3×14 r2
/// gap 2.5, scaleY .3↔1, 0.8s ease-in-out alternate, delays
/// −.1 / −.45 / −.7 / −.25s. The only designed motion in the app.
class EqBars extends StatefulWidget {
  const EqBars({super.key, required this.color, this.animate = true});

  final Color color;

  /// False in the paused tile state (S01-2: "no eq animation").
  final bool animate;

  @override
  State<EqBars> createState() => _EqBarsState();
}

class _EqBarsState extends State<EqBars> with SingleTickerProviderStateMixin {
  /// One full CSS `alternate` cycle: 0.8s forward + 0.8s back.
  static const _cycleSeconds = 1.6;
  static const _delays = [-.1, -.45, -.7, -.25]; // seconds, CSS animation-delay

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: (_cycleSeconds * 1000) ~/ 1));
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(EqBars old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Scale of bar [i]: triangle wave over the 1.6s cycle (alternate),
  /// eased per 0.8s leg, offset by the bar's negative delay.
  double _scale(int i) {
    final elapsed = _controller.value * _cycleSeconds;
    var phase = ((elapsed - _delays[i]) % _cycleSeconds) / _cycleSeconds;
    if (phase < 0) phase += 1;
    final leg = phase < .5 ? phase * 2 : (1 - phase) * 2;
    return .3 + Curves.easeInOut.transform(leg) * .7;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 2.5),
              Transform.scale(
                scaleY: widget.animate ? _scale(i) : 1,
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
