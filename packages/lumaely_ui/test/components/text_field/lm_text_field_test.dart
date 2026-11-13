import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(20), child: child),
    ),
  );
}

/// what a screen reader says for the field
String _spokenLabel(WidgetTester tester) {
  return tester.getSemantics(find.byType(LmTextField)).getSemanticsData().label;
}

void main() {
  testWidgets('screen readers get the label with the field', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const LmTextField(label: 'Email')));

    expect(_spokenLabel(tester), contains('Email'));
    semantics.dispose();
  });

  testWidgets('screen readers get the error with the field', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        const LmTextField(label: 'Password', error: 'Wrong email or password.'),
      ),
    );

    expect(_spokenLabel(tester), contains('Wrong email or password.'));
    semantics.dispose();
  });

  testWidgets('password is hidden until the eye button is pressed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const LmTextField(label: 'Password', password: true)),
    );
    bool hidden() =>
        tester.widget<TextField>(find.byType(TextField)).obscureText;

    expect(hidden(), isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(hidden(), isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('keyboards never learn from what is typed', (tester) async {
    await tester.pumpWidget(_app(const LmTextField(label: 'Journal')));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enableIMEPersonalizedLearning, isFalse);
  });

  // flutter's built in a11y checks, on a plain field, a field with an error
  // and a password field, in both themes
  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name meets the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const Column(
            spacing: 16,
            children: [
              LmTextField(label: 'Email', hint: 'name@example.com'),
              LmTextField(label: 'Password', error: 'Wrong password.'),
              LmTextField(label: 'New password', password: true),
            ],
          ),
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
