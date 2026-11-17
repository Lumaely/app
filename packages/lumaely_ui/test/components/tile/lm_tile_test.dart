import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Center(
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    ),
  );
}

LmTileGroup _group({int rows = 3, String? title = 'Settings'}) {
  return LmTileGroup(
    title: title,
    children: [
      for (var i = 0; i < rows; i++)
        LmTileRow(
          leading: const LmTileIcon(LmIcons.bell),
          title: 'Row $i',
          value: 'Value $i',
          onTap: () {},
        ),
    ],
  );
}

void main() {
  group('LmTileGroup', () {
    testWidgets('puts a divider between rows only', (tester) async {
      await tester.pumpWidget(_app(_group(rows: 4)));

      expect(find.byType(LmTileRow), findsNWidgets(4));
      expect(find.byType(Divider), findsNWidgets(3));
    });

    testWidgets('has no divider with one row', (tester) async {
      await tester.pumpWidget(_app(_group(rows: 1)));

      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('reads its title as a heading', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(_group()));

      expect(
        tester.getSemantics(find.text('Settings')),
        isSemantics(label: 'Settings', isHeader: true),
      );
      semantics.dispose();
    });

    testWidgets('has no title when none is given', (tester) async {
      await tester.pumpWidget(_app(_group(title: null)));

      expect(find.text('Settings'), findsNothing);
    });
  });

  group('LmTileRow', () {
    testWidgets('calls onTap and shows a chevron when tappable', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          LmTile(
            child: LmTileRow(title: 'Appearance', onTap: () => taps++),
          ),
        ),
      );

      await tester.tap(find.byType(LmTileRow));

      expect(taps, 1);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(LmIcon), findsOneWidget);
    });

    testWidgets('has no chevron and no ink when not tappable', (tester) async {
      await tester.pumpWidget(
        _app(const LmTile(child: LmTileRow(title: 'Version'))),
      );

      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(LmIcon), findsNothing);
    });

    testWidgets('is one button for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          LmTile(
            child: LmTileRow(
              leading: const LmTileIcon(LmIcons.appearance),
              title: 'Appearance',
              subtitle: 'Dawn by day',
              value: 'Automatic',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(LmTileRow)),
        matchesSemantics(
          label: 'Appearance\nDawn by day\nAutomatic',
          isButton: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('is at least ${LmTileRow.minHeight} high', (tester) async {
      await tester.pumpWidget(
        _app(const LmTile(child: LmTileRow(title: 'Version'))),
      );

      expect(
        tester.getSize(find.byType(LmTileRow)).height,
        greaterThanOrEqualTo(LmTileRow.minHeight),
      );
    });

    testWidgets('keeps the value on the title line', (tester) async {
      await tester.pumpWidget(
        _app(
          const LmTile(
            child: LmTileRow(title: 'Appearance', value: 'Automatic'),
          ),
        ),
      );

      final title = tester.getRect(find.text('Appearance'));
      final value = tester.getRect(find.text('Automatic'));
      expect(value.left, greaterThan(title.right));
    });

    testWidgets('wraps long texts at text scale 200 %', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        _app(
          LmTile(
            child: LmTileRow(
              leading: const LmTileIcon(LmIcons.bell),
              title: 'Reminder for the evening moment',
              subtitle: 'Only on the days you did not write',
              value: 'Every day at 21:00',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // value under the title, not squeezed next to it
      final title = tester.getRect(find.textContaining('Reminder'));
      final value = tester.getRect(find.text('Every day at 21:00'));
      expect(value.top, greaterThan(title.bottom));
    });

    testWidgets('shows a focus ring with the keyboard', (tester) async {
      await tester.pumpWidget(
        _app(
          LmTile(
            child: LmTileRow(title: 'Appearance', onTap: () {}),
          ),
        ),
      );
      final focus = LmThemeData.dawn.extension<LmTheme>()!.colors.focus;
      bool isRing(Widget widget) {
        return widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border?.top.color == focus;
      }

      expect(find.byWidgetPredicate(isRing), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(find.byWidgetPredicate(isRing), findsOneWidget);
    });
  });

  // flutter's built in a11y checks, in both themes
  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name tile group meets the accessibility guidelines', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(_group(), theme: theme));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
