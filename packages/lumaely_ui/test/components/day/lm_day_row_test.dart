import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

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

// thursday
final _date = LocalDate(2026, 10, 29);

final _moments = MomentMoods(const {
  Moment.morning: MoodScore.great,
  Moment.noon: MoodScore.good,
  Moment.afternoon: MoodScore.okay,
  Moment.evening: MoodScore.low,
});

DayEntry _entry({DayMoods? moods, String journal = ''}) {
  final now = DateTime.utc(2026, 11, 17);
  return DayEntry(
    id: 'id',
    date: _date,
    moods: moods ?? _moments,
    journal: journal,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  testWidgets('shows the date, the mood line and the journal', (tester) async {
    final entry = _entry(journal: 'Long walk by the water.');
    await tester.pumpWidget(_app(LmTile(child: LmDayRow(entry: entry))));

    expect(find.text('Thursday, Oct 29'), findsOneWidget);
    expect(find.text(moodLine(entry.moods)), findsOneWidget);
    expect(find.text('Long walk by the water.'), findsOneWidget);

    final dot = tester.widget<LmMoodDot>(find.byType(LmMoodDot));
    expect(dot.average, entry.moods.average);
  });

  testWidgets('keeps the journal to one line', (tester) async {
    final journal = 'A very long day. ' * 20;
    await tester.pumpWidget(
      _app(
        LmTile(
          child: LmDayRow(entry: _entry(journal: journal)),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text(journal.trim()));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  test('firstLine skips empty lines and trims', () {
    expect(
      LmDayRow.firstLine('\n  \n  Morning run  \nthen work'),
      'Morning run',
    );
    expect(LmDayRow.firstLine('   \n '), isNull);
    expect(LmDayRow.firstLine(''), isNull);
  });

  testWidgets('hides the journal line when the journal is empty', (
    tester,
  ) async {
    await tester.pumpWidget(_app(LmTile(child: LmDayRow(entry: _entry()))));

    final texts = tester.widgetList<Text>(find.byType(Text));
    expect(texts, hasLength(2));
  });

  testWidgets('is one button with a spoken label', (tester) async {
    final semantics = tester.ensureSemantics();
    final entry = _entry(journal: 'Long walk.');
    await tester.pumpWidget(
      _app(
        LmTile(
          child: LmDayRow(entry: entry, onTap: () {}),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(LmDayRow)),
      matchesSemantics(
        label:
            'Thursday, October 29. ${moodSemantics(entry.moods)}. '
            'Journal: Long walk.',
        isButton: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('fits at text scale 200 %', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      _app(
        LmTile(
          child: LmDayRow(
            entry: _entry(journal: 'Coffee with friends, then the market.'),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  // flutter's built in a11y checks, in both themes
  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name day rows meet the accessibility guidelines', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          LmTileGroup(
            title: 'October 2026',
            titleVariant: LmTileGroupTitleVariant.heading,
            children: [
              LmDayRow(
                entry: _entry(journal: 'Long walk.'),
                onTap: () {},
              ),
              LmDayRow(
                entry: _entry(moods: const WholeDayMood(MoodScore.great)),
                onTap: () {},
              ),
            ],
          ),
          theme: theme,
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
