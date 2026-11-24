import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app({required int current, required int count, ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Center(
        child: LmProgressSteps(current: current, count: count),
      ),
    ),
  );
}

void main() {
  testWidgets('one bar per step, filled up to the current one', (tester) async {
    await tester.pumpWidget(_app(current: 2, count: 3));

    final bars = tester.widgetList<Container>(
      find.descendant(
        of: find.byType(LmProgressSteps),
        matching: find.byType(Container),
      ),
    );
    expect(bars.map((bar) => (bar.decoration! as BoxDecoration).color), [
      LmColors.dawn.actionPrimary,
      LmColors.dawn.actionPrimary,
      LmColors.dawn.border,
    ]);
  });

  testWidgets('screen readers hear the step', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(current: 1, count: 2));

    expect(find.bySemanticsLabel('Step 1 of 2'), findsOneWidget);
    semantics.dispose();
  });
}
