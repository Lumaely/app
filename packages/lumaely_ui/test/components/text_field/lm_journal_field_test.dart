import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    ),
  );
}

// the box is drawn around it
double _height(WidgetTester tester) =>
    tester.getSize(find.byType(EditableText)).height;

void main() {
  testWidgets('grows with the text', (tester) async {
    const style = LmTypography.journal;
    final empty = style.fontSize! * style.height! * LmJournalField.minLines;
    await tester.pumpWidget(_app(const LmJournalField()));
    expect(_height(tester), moreOrLessEquals(empty, epsilon: 1));

    await tester.enterText(find.byType(TextField), 'A line\n' * 20);
    await tester.pump();

    expect(_height(tester), greaterThan(empty));
  });

  testWidgets('a tap anywhere in it starts writing', (tester) async {
    await tester.pumpWidget(_app(const LmJournalField()));

    await tester.tapAt(
      tester.getBottomRight(find.byType(LmJournalField)) - const Offset(20, 20),
    );
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
  });

  testWidgets('a tap outside stops writing', (tester) async {
    await tester.pumpWidget(_app(const LmJournalField()));
    await tester.tap(find.byType(LmJournalField));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tapAt(const Offset(400, 580));
    await tester.pump();

    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('says what is typed', (tester) async {
    String? typed;
    await tester.pumpWidget(
      _app(LmJournalField(onChanged: (text) => typed = text)),
    );

    await tester.enterText(find.byType(TextField), 'Long walk');

    expect(typed, 'Long walk');
  });

  testWidgets('read only: keeps its text', (tester) async {
    final controller = TextEditingController(text: 'Long walk');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(LmJournalField(controller: controller, readOnly: true)),
    );

    await tester.enterText(find.byType(TextField), 'Rain');

    expect(controller.text, 'Long walk');
  });

  testWidgets('keyboards never learn from what is typed', (tester) async {
    await tester.pumpWidget(_app(const LmJournalField()));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enableIMEPersonalizedLearning, isFalse);
  });

  testWidgets('screen readers get a name', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const LmJournalField()));

    expect(
      tester.getSemantics(find.byType(LmJournalField)),
      isSemantics(label: 'Journal', isTextField: true),
    );
    semantics.dispose();
  });

  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name meets the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(const LmJournalField(), theme: theme));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
