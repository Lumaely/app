import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

const _tabs = [
  LmTab(icon: LmIcons.today, label: 'Today'),
  LmTab(icon: LmIcons.journal, label: 'Journal'),
  LmTab(icon: LmIcons.insights, label: 'Insights'),
  LmTab(icon: LmIcons.settings, label: 'Settings'),
];

Widget _app({
  int selected = 0,
  ValueChanged<int>? onSelected,
  ThemeData? theme,
  double textScale = 1,
}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        bottomNavigationBar: LmTabBar(
          tabs: _tabs,
          selectedIndex: selected,
          onSelected: onSelected ?? (_) {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('tapping a tab gives its index', (tester) async {
    int? tapped;
    await tester.pumpWidget(_app(onSelected: (index) => tapped = index));

    await tester.tap(find.text('Insights'));

    expect(tapped, 2);
  });

  testWidgets('the selected tab is in the primary color, the others not', (
    tester,
  ) async {
    await tester.pumpWidget(_app(selected: 1));
    final colors = LmThemeData.dawn.extension<LmTheme>()!.colors;
    Color? iconColor(int index) =>
        IconTheme.of(tester.element(find.byType(LmIcon).at(index))).color;

    expect(iconColor(1), colors.actionPrimary);
    expect(iconColor(0), colors.textSecondary);
  });

  testWidgets('screen readers hear which tab is selected', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(selected: 1));

    expect(
      tester.getSemantics(find.text('Journal')),
      isSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('Today')),
      isSemantics(isSelected: false),
    );
    semantics.dispose();
  });

  testWidgets('no tooltip on long press: the label is always shown', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    await tester.longPress(find.text('Journal'));
    await tester.pumpAndSettle();

    // a tooltip would show the label a second time
    expect(find.text('Journal'), findsOneWidget);
  });

  testWidgets('large text fits', (tester) async {
    await tester.pumpWidget(_app(textScale: 2));

    expect(tester.takeException(), isNull);
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
