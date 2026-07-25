import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prism_venues/data/mock/mock_playback_repo.dart';
import 'package:prism_venues/data/repositories/playback_repo.dart';
import 'package:prism_venues/main.dart';
import 'package:prism_venues/shared/widgets/mood_tile.dart';

/// §2 S01 Floor behavior against the Marina Café seed: default state,
/// confirm-before-switch (S01-3), pause/resume (S01-2 ⇄ S01-1), account
/// menu sign-out (§2.0).
void main() {
  Future<void> pumpFloor(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
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
    await tester.enterText(find.byType(TextField).first, 'floor@marinacafe.com');
    await tester.tap(find.text('Sign in'));
    await _settle(tester);
  }

  testWidgets('S01-1 default: Marina Café seed state', (tester) async {
    await pumpFloor(tester);

    expect(find.text('NOW PLAYING'), findsOneWidget);
    // Hero mood name + playing tile name + schedule-rail current row.
    expect(find.text('Afternoon lift'), findsNWidgets(3));
    expect(find.text('Prism is driving'), findsOneWidget);
    expect(find.text('mid-afternoon · ~60% full · clear'), findsOneWidget);
    expect(find.text('Noise'), findsOneWidget);
    expect(find.text('62%'), findsOneWidget);
    expect(find.text('Take over'), findsOneWidget);

    // Moods block.
    expect(find.text('Moods'), findsOneWidget);
    expect(find.text('Tap to change the vibe · one tap'), findsOneWidget);

    // Schedule rail: header, Auto chip, NOW badge, up-next tag.
    expect(find.text("TODAY'S SCHEDULE"), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('NOW'), findsOneWidget);
    expect(find.text('up next'), findsOneWidget);
  });

  testWidgets('S01-3 confirm gate: cancel keeps mood, confirm switches',
      (tester) async {
    await pumpFloor(tester);

    // The rail shows mood names too — scope tile taps to the MoodTile.
    final eveningTile = find.descendant(
        of: find.byType(MoodTile), matching: find.text('Evening warmth'));

    // Tap an idle tile → confirm dialog.
    await tester.tap(eveningTile);
    await _settle(tester);
    expect(find.text('Switch to Evening warmth?'), findsOneWidget);
    expect(find.textContaining('energy 3/5', findRichText: true),
        findsOneWidget);

    // Cancel → no change (dismiss to parent, no state change §4).
    await tester.tap(find.text('Cancel'));
    await _settle(tester);
    expect(find.text('Afternoon lift'), findsNWidgets(3));

    // Confirm → the room switches.
    await tester.tap(eveningTile);
    await _settle(tester);
    await tester.tap(find.text('Switch the vibe'));
    await _settle(tester);
    // Hero + playing tile switch; the rail keeps showing the schedule.
    expect(find.text('Evening warmth'), findsNWidgets(3)); // hero+tile+rail
    expect(find.text('Afternoon lift'), findsNWidgets(2)); // idle tile+rail
    expect(find.text('Prism is driving'), findsOneWidget);
  });

  testWidgets('S01-2 pause/resume via the hero button', (tester) async {
    await pumpFloor(tester);

    await tester.tap(find.byIcon(LucideIcons.pause));
    await _settle(tester);
    expect(find.textContaining('tap play to resume', findRichText: true),
        findsOneWidget);
    expect(find.text('Prism is driving'), findsNothing);

    await tester.tap(find.byIcon(LucideIcons.play));
    await _settle(tester);
    expect(find.text('Prism is driving'), findsOneWidget);
  });

  testWidgets('account menu: avatar → Sign out → back to sign-in',
      (tester) async {
    await pumpFloor(tester);

    await tester.tap(find.text('PN'));
    await _settle(tester);
    expect(find.text('Priya Nair'), findsOneWidget);
    expect(find.text('Floor staff'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await _settle(tester);
    expect(find.text('Hello!'), findsOneWidget);
  });
}

/// Bounded settle — Floor's EqBars loop never lets pumpAndSettle rest.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
}
