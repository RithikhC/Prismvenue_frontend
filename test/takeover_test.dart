import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_venues/data/mock/mock_playback_repo.dart';
import 'package:prism_venues/data/repositories/playback_repo.dart';
import 'package:prism_venues/main.dart';

/// §2 S02 Takeover: options → active countdown → extend → confirm return,
/// plus the automatic hand-back (§6-A7).
void main() {
  Future<ProviderContainer> pumpTakeover(WidgetTester tester) async {
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
    await tester.tap(find.text('Take over'));
    await _settle(tester);
    return container;
  }

  testWidgets('S02-1 options: cards, duration seg, dynamic helper',
      (tester) async {
    await pumpTakeover(tester);

    expect(find.text('Use your own audio'), findsOneWidget);
    expect(
        find.textContaining('Plug in a phone, laptop, mixer'), findsOneWidget);
    expect(find.text('Just change the vibe'), findsOneWidget);
    expect(find.text('Hand back to Prism after'), findsOneWidget);
    expect(find.text('30 mins'), findsOneWidget);
    expect(find.text('Returns automatically after 30 minutes.'),
        findsOneWidget);

    await tester.tap(find.text('1 hour'));
    await _settle(tester);
    expect(find.text('Returns automatically after 1 hour.'), findsOneWidget);
  });

  testWidgets('S02-2 active: banner, ticking countdown, extend adds time',
      (tester) async {
    final container = await pumpTakeover(tester);

    await tester.tap(find.text('1 hour'));
    await _settle(tester);
    await tester.tap(find.text('Start takeover'));
    await _settle(tester);

    expect(find.text("You're in control"), findsOneWidget);
    expect(find.textContaining('Prism is handed off'), findsOneWidget);
    expect(find.text('Prism returns in'), findsOneWidget);
    // 1 hour shows h:mm at first ("1:00"); a few fake-clock seconds later it
    // drops under the hour and ticks m:ss (§6-A7).
    await tester.pump(const Duration(seconds: 5));
    expect(find.textContaining('59:5'), findsOneWidget);

    // Extend (S02-4 "More time") with its live "New return" preview.
    await tester.tap(find.text('Running long? Extend'));
    await _settle(tester);
    expect(find.text('More time'), findsOneWidget);
    expect(find.text('New return'), findsOneWidget);
    await tester.tap(find.text('+15 min'));
    await _settle(tester);
    await tester.tap(find.text('Push it back'));
    await _settle(tester);
    // ~59:4x remaining + 15:00 ≈ 74 min → h:mm.
    expect(find.textContaining('1:14'), findsOneWidget);

    // End the takeover so its 1s ticker isn't pending when the test-body
    // timer invariant runs (teardown disposal happens after that check).
    await container.read(playbackRepoProvider).endTakeover();
    await _settle(tester);
  });

  testWidgets('S02-3 confirm return: cancel stays, confirm lands on Floor '
      'and resets takeover', (tester) async {
    await pumpTakeover(tester);
    await tester.tap(find.text('Start takeover'));
    await _settle(tester);

    await tester.tap(find.text('Return to Prism now'));
    await _settle(tester);
    expect(find.text('Return to Prism now?'), findsOneWidget);
    expect(find.textContaining('Afternoon lift', findRichText: true),
        findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await _settle(tester);
    expect(find.text("You're in control"), findsOneWidget);

    await tester.tap(find.text('Return to Prism now'));
    await _settle(tester);
    await tester.tap(find.text('Return to Prism'));
    await _settle(tester);
    expect(find.text('NOW PLAYING'), findsOneWidget);

    // Takeover ended: /takeover shows the options again.
    await tester.tap(find.text('Take over'));
    await _settle(tester);
    expect(find.text('Use your own audio'), findsOneWidget);
  });

  testWidgets('countdown reaching zero hands back automatically',
      (tester) async {
    await pumpTakeover(tester);
    await tester.tap(find.text('15 mins'));
    await _settle(tester);
    await tester.tap(find.text('Start takeover'));
    await _settle(tester);
    expect(find.text("You're in control"), findsOneWidget);

    await tester.pump(const Duration(minutes: 16));
    await _settle(tester);
    expect(find.text('Use your own audio'), findsOneWidget,
        reason: 'auto hand-back should return to the S02-1 options');
  });

  testWidgets('S02-4 remove auto-return: countdown becomes elapsed, '
      'Extend disappears, end still works', (tester) async {
    final container = await pumpTakeover(tester);
    await tester.tap(find.text('Start takeover'));
    await _settle(tester);

    await tester.tap(find.text('Running long? Extend'));
    await _settle(tester);
    await tester.tap(find.text('Remove auto-return instead'));
    await _settle(tester);

    // No deadline: the countdown block flips to elapsed time and there is
    // nothing left to extend.
    expect(find.text('Auto-return is off'), findsOneWidget);
    expect(find.text('Running long? Extend'), findsNothing);
    expect(find.text('Return to Prism now'), findsOneWidget,
        reason: 'handing back manually must still be possible');

    // The footer keeps its "Started by …" line.
    expect(find.textContaining('Started by Priya N'), findsOneWidget);

    // End so the 1s elapsed heartbeat isn't a pending timer at teardown.
    await container.read(playbackRepoProvider).endTakeover();
    await _settle(tester);
  });
}

/// Bounded settle — chrome may host looping animations.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(seconds: 1));
}
