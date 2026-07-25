import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Prism Venues type styles — README §1.4.
///
/// Fonts: Newsreader (serif; headings & mood names — mood names italic) and
/// Hanken Grotesk (all UI). Styles are colorless; call sites apply palette
/// colors. Where §1.4 gives a range (body 14/400–600, meta 11.5–12.5…), the
/// base style here uses the range's primary value and per-use variants pinned
/// by the spec get their own named style. Floor rule: never below 10px.
class PrismType {
  PrismType._();

  // ---- Newsreader (serif) ----

  /// Sign-in "Hello!", reset headings — 34/700, lh 1.05.
  static TextStyle get displaySerif =>
      GoogleFonts.newsreader(fontSize: 34, fontWeight: FontWeight.w700, height: 1.05);

  /// Mood name in Floor hero — 31/600 italic, lh 1.1.
  static TextStyle get moodNameHero => GoogleFonts.newsreader(
      fontSize: 31, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, height: 1.1);

  /// e.g. "Open hours", "Settings" — 22/700.
  static TextStyle get screenTitle =>
      GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w700);

  /// Confirm dialogs — 21/700.
  static TextStyle get dialogTitle =>
      GoogleFonts.newsreader(fontSize: 21, fontWeight: FontWeight.w700);

  /// Bottom sheets — 20/700.
  static TextStyle get sheetTitle =>
      GoogleFonts.newsreader(fontSize: 20, fontWeight: FontWeight.w700);

  /// "Moods" — 19/600.
  static TextStyle get sectionH2 =>
      GoogleFonts.newsreader(fontSize: 19, fontWeight: FontWeight.w600);

  /// Mood name on tiles (`.tname`) — 19/600 italic.
  static TextStyle get moodNameTile => GoogleFonts.newsreader(
      fontSize: 19, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic);

  // ---- Hanken Grotesk (UI) ----

  /// Takeover countdown (amber) — 64/800.
  static TextStyle get numeralHuge =>
      GoogleFonts.hankenGrotesk(fontSize: 64, fontWeight: FontWeight.w800);

  /// Time-dial readout — 58/800, ls −0.02em.
  static TextStyle get numeralDial => GoogleFonts.hankenGrotesk(
      fontSize: 58, fontWeight: FontWeight.w800, letterSpacing: -0.02 * 58);

  /// OTP digit — 24/800.
  static TextStyle get otpDigit =>
      GoogleFonts.hankenGrotesk(fontSize: 24, fontWeight: FontWeight.w800);

  /// Body — 14 (range /400–600; base 400).
  static TextStyle get body =>
      GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w400);

  /// Buttons — 14/700.
  static TextStyle get button =>
      GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w700);

  /// Row titles — 13.5/600 (bodySm range 13–13.5/600–700).
  static TextStyle get bodySm =>
      GoogleFonts.hankenGrotesk(fontSize: 13.5, fontWeight: FontWeight.w600);

  /// Dialog body — 13.5/400, lh 1.5.
  static TextStyle get dialogBody =>
      GoogleFonts.hankenGrotesk(fontSize: 13.5, fontWeight: FontWeight.w400, height: 1.5);

  /// Tile meta — 11.5 (meta range 11.5–12.5/400–700).
  static TextStyle get meta =>
      GoogleFonts.hankenGrotesk(fontSize: 11.5, fontWeight: FontWeight.w400);

  /// Field labels (textSecondary), nav labels — 11 (/600–700; base 600).
  static TextStyle get label =>
      GoogleFonts.hankenGrotesk(fontSize: 11, fontWeight: FontWeight.w600);

  /// Uppercase caps label ("NOW PLAYING", rail header) — 10–11/700,
  /// ls .06–.12em. Base: 10/700 ls .06em; adjust per use via [caps].
  static TextStyle get labelCaps => caps(10);

  /// Caps-label helper: size 10–11, letter-spacing in em (.06–.12).
  static TextStyle caps(double size, {double lsEm = .06, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.hankenGrotesk(fontSize: size, fontWeight: weight, letterSpacing: lsEm * size);

  /// Pills — 10/700 (micro range 10–10.5/600–800).
  static TextStyle get micro =>
      GoogleFonts.hankenGrotesk(fontSize: 10, fontWeight: FontWeight.w700);

  /// NOW badge — 10/800.
  static TextStyle get nowBadge =>
      GoogleFonts.hankenGrotesk(fontSize: 10, fontWeight: FontWeight.w800);

  /// Helpers under fields/segs — 10.5/600.
  static TextStyle get microHelper =>
      GoogleFonts.hankenGrotesk(fontSize: 10.5, fontWeight: FontWeight.w600);
}
