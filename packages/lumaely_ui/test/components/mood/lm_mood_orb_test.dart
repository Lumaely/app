import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(MoodScore? score) {
  return MaterialApp(
    theme: LmThemeData.dawn,
    home: Scaffold(
      body: Center(child: LmMoodOrb(score: score)),
    ),
  );
}

void main() {
  const colors = LmColors.dawn;

  RenderObject orbOf(WidgetTester tester) {
    return tester.renderObject(
      find.descendant(
        of: find.byType(LmMoodOrb),
        matching: find.byType(CustomPaint),
      ),
    );
  }

  testWidgets('a score: its color and a dark outline', (tester) async {
    await tester.pumpWidget(_app(MoodScore.good));

    expect(
      tester.getSize(find.byType(LmMoodOrb)),
      const Size.square(LmMoodOrb.size),
    );
    expect(
      orbOf(tester),
      paints
        ..circle(color: colors.mood(MoodScore.good))
        ..circle(color: colors.textPrimary),
    );
  });

  testWidgets('no score: a dashed circle', (tester) async {
    await tester.pumpWidget(_app(null));

    expect(orbOf(tester), paints..arc(color: colors.borderStrong));
  });

  testWidgets('is hidden from screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(MoodScore.good));

    expect(
      find.descendant(
        of: find.byType(LmMoodOrb),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
