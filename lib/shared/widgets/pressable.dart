import 'package:flutter/material.dart';

import '../../theme/palette.dart';

/// §6-A2 pressed states (not designed — derived): 92% scale on filled
/// buttons, `tile2` flash on rows. No effect while [onTap] is null
/// (disabled rows/buttons stay inert).
enum PressEffect { scale, flash }

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.effect = PressEffect.scale,
    this.borderRadius = 12,
  });

  final Widget child;
  final VoidCallback? onTap;
  final PressEffect effect;

  /// Flash overlay corner radius — match the row's own radius.
  final double borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  var _pressed = false;

  void _set(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final active = widget.onTap != null;

    final content = switch (widget.effect) {
      PressEffect.scale => AnimatedScale(
          scale: _pressed ? .92 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.ease,
          child: widget.child,
        ),
      PressEffect.flash => Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _pressed ? .45 : 0,
                  duration: const Duration(milliseconds: 90),
                  curve: Curves.ease,
                  child: Container(
                    decoration: BoxDecoration(
                      color: palette.tile2,
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: active ? (_) => _set(true) : null,
      onTapUp: active ? (_) => _set(false) : null,
      onTapCancel: active ? () => _set(false) : null,
      child: content,
    );
  }
}
