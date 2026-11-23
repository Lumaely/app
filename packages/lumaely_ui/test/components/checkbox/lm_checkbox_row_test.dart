import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app({
  required bool value,
  ValueChanged<bool>? onChanged,
  String? error,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LmCheckboxRow(
          label: 'I saved my recovery key somewhere safe',
          value: value,
          onChanged: onChanged ?? (_) {},
          error: error,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a tap on the sentence toggles it', (tester) async {
    bool? next;
    await tester.pumpWidget(_app(value: false, onChanged: (v) => next = v));

    await tester.tap(find.text('I saved my recovery key somewhere safe'));

    expect(next, isTrue);
  });

  testWidgets('checked shows a check, not only a color', (tester) async {
    await tester.pumpWidget(_app(value: false));
    expect(find.byType(LmIcon), findsNothing);

    await tester.pumpWidget(_app(value: true));
    expect(find.byType(LmIcon), findsOneWidget);
  });

  testWidgets('screen readers hear a checkbox and its state', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(value: true));

    expect(
      tester.getSemantics(find.text('I saved my recovery key somewhere safe')),
      isSemantics(
        label: 'I saved my recovery key somewhere safe',
        isChecked: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('shows its error under the row', (tester) async {
    await tester.pumpWidget(_app(value: false, error: 'Check the box.'));

    expect(find.text('Check the box.'), findsOneWidget);
  });

  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name meets the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(value: false, theme: theme));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
