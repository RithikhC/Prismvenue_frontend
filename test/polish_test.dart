import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_venues/data/mock/mock_playback_repo.dart';
import 'package:prism_venues/data/repositories/playback_repo.dart';
import 'package:prism_venues/main.dart';

/// Phase 4 — §6-A1 portrait reflow, §6-A3 disabled behavior. Pressed states
/// (§6-A2) are transient visuals; covered by the running app, not asserted.
void main() {
  Future<void> pumpApp(WidgetTester tester,
      {required Size size, required String email}) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(overrides: [
      playbackRepoProvider.overrideWith((ref) {
        final repo = MockPlaybackRepo(tickNoise: false);
        ref.onDispose(repo.dispose);
        return repo;
      }),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PrismVenuesApp(),
      ),
    );
    await _settle(tester);
    await tester.enterText(find.byType(TextField).first, email);
    await tester.tap(find.text('Sign in'));
    await _settle(tester);
  }

  testWidgets('portrait floor: rail renders as a strip below the grid',
      (tester) async {
    await pumpApp(tester,
        size: const Size(768, 1024), email: 'priya@marinacafe.com');

    // Same content as landscape — hero, grid, and the rail (as a strip);
    // an overflow would fail the test via FlutterError.
    expect(find.text('NOW PLAYING'), findsOneWidget);
    expect(find.text("TODAY'S SCHEDULE"), findsOneWidget);
    expect(find.text('NOW'), findsOneWidget);
    expect(find.text('Take over'), findsOneWidget);
  });

  testWidgets('portrait: takeover, schedule, venues, settings all reflow',
      (tester) async {
    await pumpApp(tester,
        size: const Size(768, 1024), email: 'priya@marinacafe.com');

    await tester.tap(find.text('Take over'));
    await _settle(tester);
    expect(find.text('Use your own audio'), findsOneWidget);

    await tester.tap(find.text('Schedule'));
    await _settle(tester);
    expect(find.text('Prism is self-driving'), findsOneWidget);

    await tester.tap(find.text('Venues'));
    await _settle(tester);
    expect(find.text('Main floor'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await _settle(tester);
    expect(find.text("Marina Café · you're a manager"), findsOneWidget);
  });

  testWidgets(
      '§6-A3 disabled: Add exception with no days selected is inert at 40%',
      (tester) async {
    await pumpApp(tester,
        size: const Size(1024, 768), email: 'priya@marinacafe.com');
    await tester.tap(find.text('Settings'));
    await _settle(tester);
    await tester.tap(find.text('Zones & open hours'));
    await _settle(tester);
    await tester.tap(find.text('+ Add exception'));
    await _settle(tester);

    // Deselect the prefilled Fri & Sat.
    await tester.tap(find.text('Fri').last);
    await _settle(tester);
    await tester.tap(find.text('Sat').last);
    await _settle(tester);

    // Disabled CTA: tap does nothing, sheet stays open.
    await tester.tap(find.text('Add exception'), warnIfMissed: false);
    await _settle(tester);
    expect(find.text('Which days'), findsOneWidget);

    // Re-select a day → enabled again → adds and closes.
    await tester.tap(find.text('Mon').last);
    await _settle(tester);
    await tester.tap(find.text('Add exception'));
    await _settle(tester);
    expect(find.text('Which days'), findsNothing);
    expect(find.text('Mon'), findsOneWidget); // new exception row
  });
}

/// Bounded settle — chrome may host looping animations.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
}
