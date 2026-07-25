import 'package:flutter/widgets.dart';

/// Spacing scale & radii — README §1.5 / §1.6.
///
/// Design px map to Flutter logical dp 1:1 (860×602 frame, §Target).
/// Two-value paddings in the spec follow CSS shorthand: `24,22` / "24×22"
/// = vertical 24, horizontal 22.
class Dimens {
  Dimens._();

  // ---- §1.5 spacing scale ----
  static const s2 = 2.0;
  static const s4 = 4.0;
  static const s6 = 6.0;
  static const s8 = 8.0;
  static const s9 = 9.0;
  static const s10 = 10.0;
  static const s12 = 12.0;
  static const s14 = 14.0;
  static const s16 = 16.0;
  static const s18 = 18.0;
  static const s20 = 20.0;
  static const s22 = 22.0;
  static const s30 = 30.0;

  /// Screen body padding 15–18.
  static const screenPadMin = 15.0;
  static const screenPadMax = 18.0;

  /// Card padding — hero: 24×22 (v×h).
  static const heroCardPad = EdgeInsets.symmetric(vertical: 24, horizontal: 22);

  /// Card padding — tiles / list rows: 13×15 (v×h).
  static const tilePad = EdgeInsets.symmetric(vertical: 13, horizontal: 15);
  static const listRowPad = EdgeInsets.symmetric(vertical: 13, horizontal: 15);

  /// Card padding — rail, forms: 16.
  static const railPad = EdgeInsets.all(16);
  static const formPad = EdgeInsets.all(16);

  /// Field label margin: 16 top / 8 bottom.
  static const fieldLabelMargin = EdgeInsets.only(top: 16, bottom: 8);

  // ---- §1.6 radii ----

  /// Pills, seg toggles, sign-in fields & buttons, sliders.
  static const rPill = 999.0;

  /// Screen corner — frame presentation only, not used in-app.
  static const rScreen = 20.0;

  /// Sheet top corners.
  static const rSheet = 20.0;

  /// Dialogs.
  static const rDialog = 18.0;

  /// Mood tiles.
  static const rMoodTile = 16.0;

  /// Hero card, take-over btn, nav active bg.
  static const rCard = 14.0;

  /// OTP boxes.
  static const rOtp = 13.0;

  /// Settings rows, sheet action buttons (11–12: upper value).
  static const rRow = 12.0;

  /// Seg containers (11–12: lower value, per §2 S02-1 seg row r11).
  static const rSeg = 11.0;

  /// Inputs, day chips (9–10: upper value).
  static const rInput = 10.0;

  /// Small icon buttons, e.g. 30×30 back button (9–10: lower value).
  static const rIconButton = 9.0;
}
