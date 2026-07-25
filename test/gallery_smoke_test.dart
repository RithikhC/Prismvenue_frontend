import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_venues/debug/widget_gallery_screen.dart';

/// Smoke test: every gallery section (both theme panels) must build and lay
/// out without errors. Layout overflows surface as test failures.
void main() {
  testWidgets('gallery renders all sections without layout errors',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: WidgetGalleryScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Drag through the whole list so every lazily-built section builds.
    final list = find.byType(ListView);
    for (var i = 0; i < 40; i++) {
      await tester.drag(list, const Offset(0, -600), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
    }
  });
}
