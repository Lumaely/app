import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('calls onPressed when tapped', (tester) async {
    var presses = 0;
    await tester.pumpWidget(
      _app(LmButton(label: 'Continue', onPressed: () => presses++)),
    );

    await tester.tap(find.text('Continue'));

    expect(presses, 1);
  });

  testWidgets('is disabled without onPressed', (tester) async {
    await tester.pumpWidget(
      _app(const LmButton(label: 'Continue', onPressed: null)),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.enabled, isFalse);
  });

  testWidgets('ignores presses while loading and keeps its label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var presses = 0;
    await tester.pumpWidget(
      _app(
        LmButton(label: 'Unlock', loading: true, onPressed: () => presses++),
      ),
    );

    await tester.tap(find.byType(LmButton));

    expect(presses, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Unlock'), findsOneWidget);
    semantics.dispose();
  });

  // flutter's built in a11y checks (tap target size, labels, text contrast)
  // for every variant, in both themes
  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    for (final variant in LmButtonVariant.values) {
      testWidgets('$name ${variant.name} meets the accessibility guidelines', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          _app(
            LmButton(label: 'Continue', variant: variant, onPressed: () {}),
            theme: theme,
          ),
        );

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }
  }
}
