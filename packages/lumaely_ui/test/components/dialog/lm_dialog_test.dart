import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

const _title = 'Remove MacBook Pro?';

Widget _host({ThemeData? theme, String message = 'It will stop syncing.'}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => LmButton(
            label: 'Open',
            onPressed: () => showLmDialog<void>(
              context,
              builder: (context) => LmDialog(
                title: _title,
                message: message,
                actions: [
                  LmButton(
                    label: 'Remove from sync',
                    variant: LmButtonVariant.danger,
                    onPressed: () => Navigator.pop(context),
                  ),
                  LmButton(
                    label: 'Cancel',
                    variant: LmButtonVariant.text,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the title, the message and the actions', (tester) async {
    await tester.pumpWidget(_host());
    await _open(tester);

    expect(find.text(_title), findsOneWidget);
    expect(find.text('It will stop syncing.'), findsOneWidget);
    expect(find.text('Remove from sync'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('is at most ${LmDialog.maxWidth} wide', (tester) async {
    await tester.pumpWidget(_host());
    await _open(tester);

    final size = tester.getSize(
      find.descendant(
        of: find.byType(LmDialog),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    expect(size.width, lessThanOrEqualTo(LmDialog.maxWidth));
  });

  testWidgets('closes with Cancel, Escape and the scrim', (tester) async {
    await tester.pumpWidget(_host());

    await _open(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(LmDialog), findsNothing);

    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(LmDialog), findsNothing);

    await _open(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(LmDialog), findsNothing);
  });

  testWidgets('is a route named by its title', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_host());
    await _open(tester);

    expect(
      find.semantics.byPredicate(
        (node) =>
            node.label == _title &&
            node.flagsCollection.namesRoute &&
            node.flagsCollection.scopesRoute,
      ),
      findsOne,
    );
    semantics.dispose();
  });

  testWidgets('scrolls instead of overflowing at text scale 200 %', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_host(message: 'It will stop syncing. ' * 20));
    await _open(tester);

    expect(tester.takeException(), isNull);
  });

  test('theme: surface raised, dialog radius, scrim', () {
    for (final (theme, colors) in [
      (LmThemeData.dawn, LmColors.dawn),
      (LmThemeData.firefly, LmColors.firefly),
    ]) {
      final dialog = theme.dialogTheme;
      expect(dialog.backgroundColor, colors.surfaceRaised);
      expect(dialog.barrierColor, colors.scrim);
      expect(
        dialog.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(LmRadius.dialog)),
        ),
      );
    }
  });

  // flutter's built in a11y checks, in both themes
  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name dialog meets the accessibility guidelines', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_host(theme: theme));
      await _open(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
