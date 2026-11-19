import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(20), child: child),
    ),
  );
}

DayEntry _entry(LocalDate date, {String journal = ''}) {
  final now = DateTime.utc(2026, 11, 17);
  return DayEntry(
    id: 'id-$date',
    date: date,
    moods: const WholeDayMood(MoodScore.good),
    journal: journal,
    createdAt: now,
    updatedAt: now,
  );
}

// the week of figma: mon oct 26 to sun nov 1; today is thursday 29
final _today = LocalDate(2026, 10, 29);
final _monday = LocalDate(2026, 10, 26);

LmWeekStrip _strip({ValueChanged<LocalDate>? onDayTap}) {
  return LmWeekStrip(
    week: _today,
    today: _today,
    entries: {
      _monday: _entry(_monday, journal: 'Long walk.'),
      _today: _entry(_today),
    },
    onDayTap: onDayTap,
  );
}

Finder _day(LocalDate date) => find.byWidgetPredicate(
  (widget) => widget is LmCalendarDay && widget.date == date,
);

void main() {
  test('mondayOf finds the monday of any day', () {
    for (var i = 0; i < 7; i++) {
      expect(LmWeekStrip.mondayOf(_monday.addDays(i)), _monday);
    }
    // a sunday belongs to the week before, not the next one
    expect(LmWeekStrip.mondayOf(LocalDate(2026, 11, 1)), _monday);
  });

  testWidgets('shows monday to sunday, across the end of the month', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_strip()));

    final days = tester
        .widgetList<LmCalendarDay>(find.byType(LmCalendarDay))
        .map((day) => day.date)
        .toList();
    expect(days, [for (var i = 0; i < 7; i++) _monday.addDays(i)]);
    expect(find.byType(LmWeekdayLetters), findsOneWidget);
  });

  testWidgets('taps past days and today, not the future', (tester) async {
    final tapped = <LocalDate>[];
    await tester.pumpWidget(_app(_strip(onDayTap: tapped.add)));

    for (var i = 0; i < 7; i++) {
      await tester.tap(_day(_monday.addDays(i)), warnIfMissed: false);
    }

    expect(tapped, [for (var i = 0; i <= 3; i++) _monday.addDays(i)]);
  });

  testWidgets('rings today and shows no journal mark', (tester) async {
    await tester.pumpWidget(_app(_strip()));

    final today = tester.widget<LmCalendarDay>(_day(_today));
    expect(today.isToday, isTrue);
    expect(find.byKey(const ValueKey('journal mark')), findsNothing);
  });

  testWidgets('still tells screen readers about the journal', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(_strip(onDayTap: (_) {})));
    final good = moodSemantics(const WholeDayMood(MoodScore.good));

    expect(
      tester.getSemantics(_day(_monday)),
      isSemantics(label: 'Monday, October 26. $good. Journal.', isButton: true),
    );
    expect(
      tester.getSemantics(_day(LocalDate(2026, 11, 1))),
      isSemantics(label: 'Sunday, November 1. Not yet.', isButton: false),
    );
    semantics.dispose();
  });

  testWidgets('fits a 320 px screen at text scale 200 %', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app(_strip(onDayTap: (_) {})));

    expect(tester.takeException(), isNull);
  });

  // flutter's built in a11y checks, in both themes
  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name week strip meets the accessibility guidelines', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(_strip(onDayTap: (_) {}), theme: theme));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
