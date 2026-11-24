import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app({VoidCallback? onPressed, ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Center(
        child: LmIconButton(
          icon: LmIcons.chevronLeft,
          label: 'Back',
          onPressed: onPressed ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a tap calls onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(onPressed: () => taps++));

    await tester.tap(find.byType(LmIconButton));

    expect(taps, 1);
  });

  // material gives icon buttons their name through the tooltip
  testWidgets('screen readers hear its label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app());

    expect(
      tester.getSemantics(find.byType(IconButton)),
      isSemantics(isButton: true, tooltip: 'Back'),
    );
    semantics.dispose();
  });

  testWidgets('a circle of its size in a 48 px touch area', (tester) async {
    await tester.pumpWidget(_app());

    expect(tester.getSize(find.byType(LmIconButton)), const Size.square(48));
    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(LmIconButton),
          matching: find.byType(Material),
        ),
      ),
      const Size.square(LmIconButton.size),
    );
  });

  testWidgets('outlined: as high as a button, in the action color', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LmThemeData.dawn,
        home: Scaffold(
          body: Center(
            child: LmIconButton(
              icon: LmIcons.chevronUpDown,
              label: 'Switch',
              outlined: true,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(LmIconButton),
        matching: find.byType(Material),
      ),
    );
    expect(
      tester.getSize(find.byWidget(material)),
      const Size.square(LmIconButton.outlinedSize),
    );
    expect(
      (material.shape! as OutlinedBorder).side.color,
      LmColors.dawn.actionPrimary,
    );
  });

  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name meets the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(theme: theme));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantics.dispose();
    });
  }
}
