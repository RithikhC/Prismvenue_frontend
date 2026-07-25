import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/router.dart';
import 'theme/palette.dart';

/// App theme mode. Dark is the design default (§1.1).
/// TODO(phase-3): persist the choice (§2.0 "Theme toggle behavior") once the
/// top-bar toggle lands.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void set(ThemeMode mode) => state = mode;

  void toggle() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

void main() {
  runApp(const ProviderScope(child: PrismVenuesApp()));
}

class PrismVenuesApp extends ConsumerWidget {
  const PrismVenuesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Prism Venues',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: buildPrismTheme(PrismPalette.light),
      darkTheme: buildPrismTheme(PrismPalette.dark),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

/// Fully custom theme (Material 3 off, §Target) built from the palette.
/// Components style themselves from `PrismPalette`/`PrismType` directly;
/// ThemeData carries only the global scaffold + base text defaults.
ThemeData buildPrismTheme(PrismPalette palette) {
  final base = ThemeData(
    useMaterial3: false,
    brightness: palette.brightness,
    scaffoldBackgroundColor: palette.screen,
    canvasColor: palette.surface,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    // §4: screen transitions are undesigned — instant (§6-B6). Sheets keep
    // their own ≤200ms slide.
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      for (final platform in TargetPlatform.values)
        platform: const _InstantTransitionsBuilder(),
    }),
  );
  return base.copyWith(
    textTheme: GoogleFonts.hankenGroteskTextTheme(base.textTheme).apply(
      bodyColor: palette.textPrimary,
      displayColor: palette.textPrimary,
    ),
    extensions: [palette],
  );
}

class _InstantTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
