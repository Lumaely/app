import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app({VoidCallback? onBack, Widget? action, ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: LmTopBar(title: 'Today', onBack: onBack, action: action),
    ),
  );
}

void main() {
  testWidgets('back calls onBack', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(onBack: () => taps++));

    await tester.tap(find.byTooltip('Back'));

    expect(taps, 1);
  });

  testWidgets('the title is a header', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(onBack: () {}));

    expect(
      tester.getSemantics(find.text('Today')),
      isSemantics(label: 'Today', isHeader: true),
    );
    semantics.dispose();
  });

  testWidgets('the action sits on the right', (tester) async {
    await tester.pumpWidget(
      _app(
        onBack: () {},
        action: LmIconButton(
          icon: LmIcons.more,
          label: 'More',
          onPressed: () {},
        ),
      ),
    );

    expect(
      tester.getCenter(find.byTooltip('More')).dx,
      greaterThan(tester.getCenter(find.text('Today')).dx),
    );
  });

  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name meets the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(onBack: () {}, theme: theme));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
