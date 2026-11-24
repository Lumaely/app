import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app({
  VoidCallback? onBack,
  Widget? action,
  ThemeData? theme,
  double textScale = 1,
}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: LmTopBar(title: 'Today', onBack: onBack, action: action),
      ),
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

  for (final textScale in [1.0, 2.0]) {
    testWidgets('the letters are centred on back at ${textScale}x', (
      tester,
    ) async {
      await tester.pumpWidget(_app(onBack: () {}, textScale: textScale));

      final title = tester.renderObject<RenderParagraph>(find.text('Today'));
      final baseline = title.getDryBaseline(
        title.constraints,
        TextBaseline.alphabetic,
      )!;
      final letters =
          LmTypography.titleLarge.fontSize! * textScale * LmLineMark.xHeight;

      expect(
        tester.getTopLeft(find.text('Today')).dy + baseline - letters / 2,
        moreOrLessEquals(
          tester.getCenter(find.byTooltip('Back')).dy,
          epsilon: 0.1,
        ),
      );
    });
  }

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
