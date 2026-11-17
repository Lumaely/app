import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

// a screen with an "Open" button that shows [sheet], keeps what it returns
Widget _host(
  Widget Function(BuildContext context) sheet, {
  ThemeData? theme,
  void Function(Object? result)? onResult,
}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => LmButton(
            label: 'Open',
            onPressed: () async {
              final result = await showLmSheet<Object>(context, builder: sheet);
              onResult?.call(result);
            },
          ),
        ),
      ),
    ),
  );
}

LmSheet _sheet(BuildContext context, {String message = 'Nothing is sent.'}) {
  return LmSheet(
    title: 'Your diary stays here',
    message: message,
    actions: [
      LmButton(
        label: 'I understand',
        onPressed: () => Navigator.pop(context, 'ok'),
      ),
      LmButton(
        label: 'Choose another option',
        variant: LmButtonVariant.text,
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the title, the message and the actions', (tester) async {
    await tester.pumpWidget(_host(_sheet));
    await _open(tester);

    expect(find.text('Your diary stays here'), findsOneWidget);
    expect(find.text('Nothing is sent.'), findsOneWidget);
    expect(find.text('I understand'), findsOneWidget);
  });

  testWidgets('returns what the action pops', (tester) async {
    Object? result;
    await tester.pumpWidget(_host(_sheet, onResult: (value) => result = value));
    await _open(tester);

    await tester.tap(find.text('I understand'));
    await tester.pumpAndSettle();

    expect(result, 'ok');
    expect(find.byType(LmSheet), findsNothing);
  });

  testWidgets('closes with Escape', (tester) async {
    await tester.pumpWidget(_host(_sheet));
    await _open(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(LmSheet), findsNothing);
  });

  testWidgets('closes with a tap on the scrim', (tester) async {
    await tester.pumpWidget(_host(_sheet));
    await _open(tester);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(LmSheet), findsNothing);
  });

  testWidgets('reads its title as a heading', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_host(_sheet));
    await _open(tester);

    expect(
      tester.getSemantics(find.text('Your diary stays here')),
      isSemantics(label: 'Your diary stays here', isHeader: true),
    );
    semantics.dispose();
  });

  testWidgets('stays above the keyboard', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(_sheet));
    await _open(tester);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    final lastAction = tester.getRect(find.text('Choose another option'));
    expect(lastAction.bottom, lessThanOrEqualTo(800 - 300));
  });

  testWidgets('scrolls instead of overflowing at text scale 200 %', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      _host((context) => _sheet(context, message: 'Nothing is sent. ' * 20)),
    );
    await _open(tester);

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(LmSheet),
        matching: find.byType(Scrollable),
      ),
      findsOneWidget,
    );
  });

  test('theme: surface raised, sheet radius, drag handle', () {
    for (final (theme, colors) in [
      (LmThemeData.dawn, LmColors.dawn),
      (LmThemeData.firefly, LmColors.firefly),
    ]) {
      final sheet = theme.bottomSheetTheme;
      expect(sheet.modalBackgroundColor, colors.surfaceRaised);
      expect(sheet.modalBarrierColor, colors.scrim);
      expect(sheet.showDragHandle, isTrue);
      expect(
        sheet.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(LmRadius.sheet),
          ),
        ),
      );
    }
  });

  // flutter's built in a11y checks, in both themes
  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name sheet meets the accessibility guidelines', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_host(_sheet, theme: theme));
      await _open(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
