import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? LmThemeData.dawn,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('screen readers get the text', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const LmPill('Day 1')));

    expect(find.bySemanticsLabel('Day 1'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('or its semantic label instead', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(const LmPill('12 days', semanticLabel: '12 days in a row')),
    );

    expect(find.text('12 days'), findsOneWidget);
    expect(find.bySemanticsLabel('12 days in a row'), findsOneWidget);
    expect(find.bySemanticsLabel('12 days'), findsNothing);
    semantics.dispose();
  });

  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name meets the contrast guideline', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(const LmPill('12 days'), theme: theme));

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
