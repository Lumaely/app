import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app({VoidCallback? onTap, ThemeData? theme, double textScale = 1}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Center(
          child: LmChoiceTile(
            icon: LmIcons.sparkles,
            title: 'I’m new',
            description: 'Start a new diary.',
            onTap: onTap ?? () {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a tap calls onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(onTap: () => taps++));

    await tester.tap(find.byType(LmChoiceTile));

    expect(taps, 1);
  });

  testWidgets('screen readers hear one button with both texts', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app());

    expect(
      tester.getSemantics(find.text('I’m new')),
      isSemantics(isButton: true, label: 'I’m new\nStart a new diary.'),
    );
    semantics.dispose();
  });

  testWidgets('is a square of its default size', (tester) async {
    await tester.pumpWidget(_app());

    expect(
      tester.getSize(find.byType(LmChoiceTile)),
      const Size.square(LmChoiceTile.size),
    );
  });

  testWidgets('grows taller with large text, nothing cut', (tester) async {
    await tester.pumpWidget(_app(textScale: 2));

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(LmChoiceTile)).height,
      greaterThan(LmChoiceTile.size),
    );
  });

  testWidgets('shows a focus ring with the keyboard', (tester) async {
    await tester.pumpWidget(_app());
    Finder ring() => find.descendant(
      of: find.byType(LmChoiceTile),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null,
      ),
    );

    expect(ring(), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    expect(ring(), findsOneWidget);
  });

  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name meets the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(theme: theme));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
