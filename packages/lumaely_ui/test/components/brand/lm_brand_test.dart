import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('the logo takes the size asked', (tester) async {
    await tester.pumpWidget(_app(const LmLogo(size: 48)));

    expect(tester.getSize(find.byType(LmLogo)), const Size.square(48));
  });

  testWidgets('screen readers skip the logo, unless it has a label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const LmLogo()));

    expect(find.bySemanticsLabel('Lumaely'), findsNothing);

    await tester.pumpWidget(_app(const LmLogo(semanticLabel: 'Lumaely')));

    expect(find.bySemanticsLabel('Lumaely'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the cover is decorative', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const LmCoverRise(size: 200)));

    expect(tester.getSize(find.byType(LmCoverRise)), const Size.square(200));
    expect(
      tester.getSemantics(find.byType(LmCoverRise)),
      isNot(isSemantics(isImage: true)),
    );
    semantics.dispose();
  });

  // both themes: the painter reads the theme's mood colors
  for (final theme in [LmThemeData.dawn, LmThemeData.firefly]) {
    testWidgets('draws in ${theme.brightness.name} without error', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const Column(children: [LmLogo(), LmCoverRise(size: 120)]),
          theme: theme,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
