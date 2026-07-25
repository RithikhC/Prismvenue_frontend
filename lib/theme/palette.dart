import 'package:flutter/material.dart';

/// Prism Venues color tokens — README §1.1 (dark) / §1.2 (light).
/// Exposed as a ThemeExtension so widgets read tokens via
/// `Theme.of(context).extension<PrismPalette>()!`.
class PrismPalette extends ThemeExtension<PrismPalette> {
  const PrismPalette({
    required this.brightness,
    required this.screen,
    required this.surface,
    required this.tile,
    required this.tile2,
    required this.tint,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.unfilled,
    required this.accent,
    required this.accentSoft,
    required this.accentText,
    required this.chipInk,
    required this.green,
    required this.red,
    required this.amber,
  });

  final Brightness brightness;

  /// Page background.
  final Color screen;

  /// Top bar, nav bar, cards, rail, sheets.
  final Color surface;

  /// Inputs, idle chips, secondary buttons.
  final Color tile;

  /// Slider tracks, toggle-off, deeper wells.
  final Color tile2;

  /// Mood-tile base under tint gradient.
  final Color tint;

  /// Hairline borders.
  final Color border;

  /// Outlined buttons, sheet top border, focused-ish.
  final Color borderStrong;

  /// Headings, values.
  final Color textPrimary;

  /// Labels, meta.
  final Color textSecondary;

  /// Hints, disabled-ish, locked nav.
  final Color textTertiary;

  /// Empty energy-bar segments.
  final Color unfilled;

  /// THE accent (copper). Primary buttons, active seg, fills, NOW badge.
  final Color accent;

  /// Active-nav bg, pills, highlighted row bg.
  final Color accentSoft;

  /// Text/icons on accentSoft.
  final Color accentText;

  /// Text ON accent fills.
  final Color chipInk;

  /// Online dots, success.
  final Color green;

  /// Destructive only (Delete, Sign out, Remove, offline).
  final Color red;

  /// Warnings, takeover countdown.
  final Color amber;

  /// §1.1 Dark theme (default).
  static const dark = PrismPalette(
    brightness: Brightness.dark,
    screen: Color(0xFF16120E),
    surface: Color(0xFF201A14),
    tile: Color(0xFF262019),
    tile2: Color(0xFF342A1E),
    tint: Color(0xFF211B13),
    border: Color.fromRGBO(246, 236, 220, .08),
    borderStrong: Color.fromRGBO(246, 236, 220, .18),
    textPrimary: Color(0xFFF7F1E7),
    textSecondary: Color(0xFFB3A794),
    textTertiary: Color(0xFF7A6F5E),
    unfilled: Color.fromRGBO(246, 236, 220, .14),
    accent: Color(0xFFC98A5E),
    accentSoft: Color.fromRGBO(201, 138, 94, .16),
    accentText: Color(0xFFDFA277),
    chipInk: Color(0xFF16120E),
    green: Color(0xFF3FB65B),
    red: Color(0xFFE5484D),
    amber: Color(0xFFF5A623),
  );

  /// §1.2 Light theme.
  static const light = PrismPalette(
    brightness: Brightness.light,
    screen: Color(0xFFF3EDE2),
    surface: Color(0xFFFCF9F2),
    tile: Color(0xFFF5EFE3),
    tile2: Color(0xFFEAE1CF),
    tint: Color(0xFFFBF7EF),
    border: Color.fromRGBO(70, 52, 28, .10),
    borderStrong: Color.fromRGBO(70, 52, 28, .22),
    textPrimary: Color(0xFF2A2318),
    textSecondary: Color(0xFF7E7260),
    textTertiary: Color(0xFFA69A85),
    unfilled: Color.fromRGBO(42, 35, 24, .12),
    accent: Color(0xFFB06F45),
    accentSoft: Color.fromRGBO(176, 111, 69, .13),
    accentText: Color(0xFF9A5F3B),
    chipInk: Color(0xFFFFFFFF),
    green: Color(0xFF2FA24A),
    red: Color(0xFFE5484D),
    amber: Color(0xFFF5A623),
  );

  // §1.7 Elevation — flat by default (borders carry structure). Only these.
  // (screenShadow from §1.1 is frame presentation only — intentionally absent.)

  static const dialogShadow = [
    BoxShadow(offset: Offset(0, 30), blurRadius: 70, color: Color.fromRGBO(0, 0, 0, .55)),
  ];

  static const sheetShadow = [
    BoxShadow(offset: Offset(0, -20), blurRadius: 60, color: Color.fromRGBO(0, 0, 0, .5)),
  ];

  static const accountMenuShadow = [
    BoxShadow(offset: Offset(0, 22), blurRadius: 54, color: Color.fromRGBO(20, 12, 4, .5)),
  ];

  /// Playing tile: `0 12px 28px moodColor@28%`.
  static List<BoxShadow> playingTileShadow(Color moodColor) => [
        BoxShadow(offset: const Offset(0, 12), blurRadius: 28, color: moodColor.withValues(alpha: .28)),
      ];

  @override
  PrismPalette copyWith({
    Brightness? brightness,
    Color? screen,
    Color? surface,
    Color? tile,
    Color? tile2,
    Color? tint,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? unfilled,
    Color? accent,
    Color? accentSoft,
    Color? accentText,
    Color? chipInk,
    Color? green,
    Color? red,
    Color? amber,
  }) {
    return PrismPalette(
      brightness: brightness ?? this.brightness,
      screen: screen ?? this.screen,
      surface: surface ?? this.surface,
      tile: tile ?? this.tile,
      tile2: tile2 ?? this.tile2,
      tint: tint ?? this.tint,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      unfilled: unfilled ?? this.unfilled,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentText: accentText ?? this.accentText,
      chipInk: chipInk ?? this.chipInk,
      green: green ?? this.green,
      red: red ?? this.red,
      amber: amber ?? this.amber,
    );
  }

  @override
  PrismPalette lerp(PrismPalette? other, double t) {
    if (other == null) return this;
    return PrismPalette(
      brightness: t < .5 ? brightness : other.brightness,
      screen: Color.lerp(screen, other.screen, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      tile: Color.lerp(tile, other.tile, t)!,
      tile2: Color.lerp(tile2, other.tile2, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      unfilled: Color.lerp(unfilled, other.unfilled, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      chipInk: Color.lerp(chipInk, other.chipInk, t)!,
      green: Color.lerp(green, other.green, t)!,
      red: Color.lerp(red, other.red, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
    );
  }
}
