import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_venues/data/mock/mock_playback_repo.dart';
import 'package:prism_venues/data/repositories/playback_repo.dart';
import 'package:prism_venues/main.dart';
import 'package:prism_venues/shared/widgets/prism_bottom_sheet.dart';

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

    expect(find.textContaining('Your audio is playing · started'),
        findsOneWidget);
    // 1 hour → "60:00", ticking every second (§6-A7 m:ss). A few seconds of
    // fake clock have elapsed across the pumps, so assert the minute mark.
    await tester.pump(const Duration(seconds: 5));
    expect(find.textContaining('59:5'), findsOneWidget);

    // Extend (sheet) — the screen also has an "Extend" button, so scope
    // the sheet's primary by type.
    await tester.tap(find.text('Extend').first);
    await _settle(tester);
    expect(find.text('Extend takeover'), findsOneWidget);
    await tester.tap(find.text('15 mins'));
    await _settle(tester);
    await tester.tap(find.descendant(
        of: find.byType(PrismBottomSheet), matching: find.text('Extend')));
    await _settle(tester);
    // ~59:5x − settles + 15:00 ≈ 74:xx.
    expect(find.textContaining('74:'), findsOneWidget);

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
    expect(find.textContaining('Your audio is playing'), findsOneWidget);

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
    expect(find.textContaining('Your audio is playing'), findsOneWidget);

    await tester.pump(const Duration(minutes: 16));
    await _settle(tester);
    expect(find.text('Use your own audio'), findsOneWidget,
        reason: 'auto hand-back should return to the S02-1 options');
  });
}

/// Bounded settle — chrome may host looping animations.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(seconds: 1));
}
