import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// Text input — §3 PrismField.
/// Auth variant (S00-1): h54, r999, bg `surface`, padding-h 20, leading icon
/// 19 `textSecondary`, text 14.5; password: 18/ls3 dots + trailing eye 18.
/// Sheet variant: r10, padding 10×13, text 13, label 11/600 mb7–8 (indent 4).
/// Focused: border 1.5 `accent`. [strongBorder] renders the idle border as
/// 1.5 `borderStrong` (S00-4 confirm field, S05-10 hours fields).
class PrismField extends StatefulWidget {
  const PrismField({
    super.key,
    this.label,
    this.controller,
    this.hint,
    this.auth = false,
    this.obscure = false,
    this.strongBorder = false,
    this.focusedOverride,
    this.leading,
    this.trailing,
    this.readOnly = false,
    this.onTap,
  });

  final String? label;
  final TextEditingController? controller;
  final String? hint;

  /// Sign-in styling (h54/r999) vs sheet styling (r10).
  final bool auth;

  final bool obscure;
  final bool strongBorder;

  /// Force the focused border (for static gallery/spec states).
  final bool? focusedOverride;

  final Widget? leading;
  final Widget? trailing;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<PrismField> createState() => _PrismFieldState();
}

class _PrismFieldState extends State<PrismField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    final focused = widget.focusedOverride ?? _focusNode.hasFocus;

    // The spec's "18/ls3" password treatment is for the typed DOTS only.
    // The hint must keep the standard field style — inheriting the dot style
    // made the "Password" placeholder render 18px wide-tracked next to
    // Email's 14.5, reading as a different font.
    final plainStyle = PrismType.body.copyWith(
        fontSize: widget.auth ? 14.5 : 13, color: palette.textPrimary);
    final textStyle = widget.obscure
        ? PrismType.body.copyWith(
            fontSize: 18, letterSpacing: 3, color: palette.textPrimary)
        : plainStyle;

    final border = focused
        ? Border.all(color: palette.accent, width: 1.5)
        : widget.strongBorder
            ? Border.all(color: palette.borderStrong, width: 1.5)
            : Border.all(color: palette.border);

    final field = Container(
      height: widget.auth ? 54 : null,
      padding: widget.auth
          ? const EdgeInsets.symmetric(horizontal: 20)
          : const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
      decoration: BoxDecoration(
        color: palette.surface,
        border: border,
        borderRadius: BorderRadius.circular(widget.auth ? 999 : 10),
      ),
      child: Row(
        children: [
          if (widget.leading != null) ...[
            IconTheme(
              data: IconThemeData(size: 19, color: palette.textSecondary),
              child: widget.leading!,
            ),
            SizedBox(width: widget.auth ? 12 : 9),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscure,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              style: textStyle,
              cursorColor: palette.accent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: widget.hint,
                hintStyle: plainStyle.copyWith(color: palette.textTertiary),
              ),
            ),
          ),
          if (widget.trailing != null) ...[
            SizedBox(width: widget.auth ? 12 : 9),
            IconTheme(
              data: IconThemeData(size: 18, color: palette.textSecondary),
              child: widget.trailing!,
            ),
          ],
        ],
      ),
    );

    if (widget.label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 7),
          child: Text(widget.label!,
              style: PrismType.label.copyWith(color: palette.textSecondary)),
        ),
        field,
      ],
    );
  }
}
