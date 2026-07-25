import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The 6-mood fixed set — README §1.3.
class Mood {
  const Mood({
    required this.id,
    required this.name,
    required this.dotDark,
    required this.dotLight,
    required this.gradStart,
    required this.gradEnd,
    required this.bpm,
    required this.energy,
  });

  final String id;
  final String name;

  /// Dot color on the dark theme.
  final Color dotDark;

  /// Dot color on the light theme.
  final Color dotLight;

  /// Playing gradient start/end (150°).
  final Color gradStart;
  final Color gradEnd;

  final int bpm;

  /// 1–5.
  final int energy;

  Color dot(Brightness b) => b == Brightness.dark ? dotDark : dotLight;

  /// Playing-state tile gradient: 150°, gradStart → gradEnd.
  LinearGradient playingGradient() => _linearGradient150([gradStart, gradEnd]);

  /// Idle mood-tile tint — §1.3: `linear-gradient(150deg, moodColor@13%,
  /// moodColor@3%)` over the palette `tint` base. The stops are
  /// pre-composited onto [over] (Flutter's BoxDecoration ignores `color`
  /// when `gradient` is set, so the CSS layering is baked in here).
  LinearGradient idleTintGradient(Brightness b, {required Color over}) {
    final c = dot(b);
    return _linearGradient150([
      Color.alphaBlend(c.withValues(alpha: .13), over),
      Color.alphaBlend(c.withValues(alpha: .03), over),
    ]);
  }

  /// Idle mood-tile border: `moodColor@22%` — §1.3.
  Color idleBorder(Brightness b) => dot(b).withValues(alpha: .22);
}

/// CSS `linear-gradient(150deg, …)` equivalent: 0° points up, angles run
/// clockwise, so the 150° direction vector is (sin 150°, −cos 150°).
LinearGradient _linearGradient150(List<Color> colors) {
  const deg = 150.0;
  final rad = deg * math.pi / 180;
  final dx = math.sin(rad);
  final dy = -math.cos(rad);
  return LinearGradient(
    begin: Alignment(-dx, -dy),
    end: Alignment(dx, dy),
    colors: colors,
  );
}

/// §1.3 table, in canonical order.
const moods = [
  Mood(
    id: 'morning-calm',
    name: 'Morning calm',
    dotDark: Color(0xFF2DD4A7),
    dotLight: Color(0xFF1FA982),
    gradStart: Color(0xFF34D3A8),
    gradEnd: Color(0xFF0FA37B),
    bpm: 80,
    energy: 2,
  ),
  Mood(
    id: 'daytime-flow',
    name: 'Daytime flow',
    dotDark: Color(0xFF84C44A),
    dotLight: Color(0xFF699F35),
    gradStart: Color(0xFF92CE58),
    gradEnd: Color(0xFF5F9427),
    bpm: 95,
    energy: 3,
  ),
  Mood(
    id: 'afternoon-lift',
    name: 'Afternoon lift',
    dotDark: Color(0xFFF5A623),
    dotLight: Color(0xFFE08F0E),
    gradStart: Color(0xFFF7AE33),
    gradEnd: Color(0xFFD9820E),
    bpm: 110,
    energy: 4,
  ),
  Mood(
    id: 'evening-warmth',
    name: 'Evening warmth',
    dotDark: Color(0xFFE86C9E),
    dotLight: Color(0xFFCB487E),
    gradStart: Color(0xFFEF7FAC),
    gradEnd: Color(0xFFD14380),
    bpm: 92,
    energy: 3,
  ),
  Mood(
    id: 'peak',
    name: 'Peak',
    dotDark: Color(0xFFF0564F),
    dotLight: Color(0xFFD83A33),
    gradStart: Color(0xFFF4685F),
    gradEnd: Color(0xFFD22F28),
    bpm: 124,
    energy: 5,
  ),
  Mood(
    id: 'wind-down',
    name: 'Wind-down',
    dotDark: Color(0xFF9A8CF0),
    dotLight: Color(0xFF6E5ED2),
    gradStart: Color(0xFFA99CF4),
    gradEnd: Color(0xFF6F5BE0),
    bpm: 68,
    energy: 1,
  ),
];

Mood moodById(String id) => moods.firstWhere((m) => m.id == id);
