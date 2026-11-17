import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child) {
  return MaterialApp(
    theme: LmThemeData.dawn,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  const colors = LmColors.dawn;

  RenderObject dotOf(WidgetTester tester) {
    return tester.renderObject(
      find.descendant(
        of: find.byType(LmMoodDot),
        matching: find.byType(CustomPaint),
      ),
    );
  }

  testWidgets('is ${LmMoodDot.defaultSize} px by default', (tester) async {
    await tester.pumpWidget(_app(const LmMoodDot(average: 4)));

    expect(
      tester.getSize(find.byType(LmMoodDot)),
      const Size.square(LmMoodDot.defaultSize),
    );
  });

  testWidgets('fills an average with the blended color', (tester) async {
    await tester.pumpWidget(_app(const LmMoodDot(average: 3.5)));

    expect(dotOf(tester), paints..circle(color: colors.moodAverage(3.5)));
  });

  testWidgets('outlines great', (tester) async {
    await tester.pumpWidget(_app(const LmMoodDot(average: 5)));

    expect(
      dotOf(tester),
      paints
        ..circle(color: colors.mood(MoodScore.great))
        ..circle(color: colors.moodOutline(MoodScore.great)),
    );
  });

  testWidgets('draws a dashed circle when empty', (tester) async {
    await tester.pumpWidget(_app(const LmMoodDot(average: null)));

    expect(dotOf(tester), paints..arc(color: colors.borderStrong));
  });

  testWidgets('is hidden from screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const LmMoodDot(average: 4)));

    expect(
      find.descendant(
        of: find.byType(LmMoodDot),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
