import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/env.dart';
import 'app/router.dart';
import 'app/session.dart';
import 'data/api/api_auth_repo.dart';
import 'data/api/api_playback_repo.dart';
import 'data/api/api_schedule_repo.dart';
import 'data/api/api_settings_repo.dart';
import 'data/api/api_venue_repo.dart';
import 'data/api/providers.dart';
import 'data/repositories/auth_repo.dart';
import 'data/repositories/playback_repo.dart';
import 'data/repositories/schedule_repo.dart';
import 'data/repositories/settings_repo.dart';
import 'data/repositories/venue_repo.dart';
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

/// Swaps the mock repositories for API-backed ones.
///
/// This is the single seam `BACKEND_INTEGRATION.md` §2 describes: one override
/// per interface, nothing else in the app changes. Repositories are migrated
/// one at a time — anything not listed here is still on its mock, which is why
/// the list grows increment by increment rather than all at once.
///
/// `--dart-define=PRISM_USE_MOCKS=true` returns an empty list, running the app
/// exactly as it ran before the backend existed. Useful for design review and
/// for reproducing the widget tests by hand.
ProviderContainer buildPrismContainer() {
  if (Env.useMocks) return ProviderContainer();
  return ProviderContainer(overrides: [
    authRepoProvider.overrideWith(
      (ref) => ApiAuthRepo(
        ref.watch(apiClientProvider),
        ref.watch(tokenStoreProvider),
      ),
    ),
    settingsRepoProvider.overrideWith((ref) {
      final repo = ApiSettingsRepo(
        ref.watch(apiClientProvider),
        ref.watch(apiScopeProvider),
      );
      ref.onDispose(repo.dispose);
      return repo;
    }),
    venueRepoProvider.overrideWith((ref) {
      final repo = ApiVenueRepo(ref.watch(apiClientProvider));
      ref.onDispose(repo.dispose);
      return repo;
    }),
    scheduleRepoProvider.overrideWith((ref) {
      final repo = ApiScheduleRepo(
        ref.watch(apiClientProvider),
        ref.watch(apiScopeProvider),
      );
      ref.onDispose(repo.dispose);
      return repo;
    }),
    playbackRepoProvider.overrideWith((ref) {
      final repo = ApiPlaybackRepo(
        ref.watch(apiClientProvider),
        ref.watch(apiScopeProvider),
        ref.watch(tokenStoreProvider),
      );
      ref.onDispose(repo.dispose);
      return repo;
    }),
  ]);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = buildPrismContainer();

  // Rehydrate before the first frame so the router sees the final session and
  // a returning user never sees the sign-in screen flash past.
  //
  // Capped, because a slow network must not hold the app hostage: if the check
  // outlives the cap we start signed out and let it finish in the background —
  // the router listens to the session, so a late success still lands the user
  // on their home screen.
  if (!Env.useMocks) {
    await container
        .read(authControllerProvider)
        .restore()
        .timeout(const Duration(seconds: 3), onTimeout: () {});
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const PrismVenuesApp(),
  ));
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
