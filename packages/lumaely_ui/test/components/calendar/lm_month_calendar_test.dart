import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
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

// october 2026 starts on a thursday; "today" is the 29th
final _today = LocalDate(2026, 10, 29);
final _withJournal = LocalDate(2026, 10, 12);
final _moodOnly = LocalDate(2026, 10, 13);

LmMonthCalendar _october({ValueChanged<LocalDate>? onDayTap}) {
  return LmMonthCalendar(
    year: 2026,
    month: 10,
    today: _today,
    entries: {
      _withJournal: _entry(_withJournal, journal: 'Long walk.'),
      _moodOnly: _entry(_moodOnly),
      _today: _entry(_today),
    },
    onDayTap: onDayTap,
  );
}

Finder _day(int day) => find.byWidgetPredicate(
  (widget) => widget is LmCalendarDay && widget.date.day == day,
);

void main() {
  testWidgets('shows the month title and every day', (tester) async {
    await tester.pumpWidget(_app(_october()));

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.byType(LmCalendarDay), findsNWidgets(31));
  });

  testWidgets('starts the weeks on monday', (tester) async {
    await tester.pumpWidget(_app(_october()));

    final monday = tester.getCenter(find.text('M'));
    final thursday = tester.getCenter(find.text('T').at(1));
    // oct 1 is a thursday, oct 5 a monday
    expect(tester.getCenter(_day(1)).dx, moreOrLessEquals(thursday.dx));
    expect(tester.getCenter(_day(5)).dx, moreOrLessEquals(monday.dx));
  });

  testWidgets('has 4 weeks for a february that starts on monday', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        LmMonthCalendar(
          year: 2027,
          month: 2,
          entries: const {},
          today: LocalDate(2027, 2, 10),
        ),
      ),
    );

    expect(find.byType(LmCalendarDay), findsNWidgets(28));
    final rows = {
      for (final element in find.byType(LmCalendarDay).evaluate())
        tester.getTopLeft(find.byWidget(element.widget)).dy,
    };
    expect(rows, hasLength(4));
  });

  testWidgets('taps past days and today, with or without entry', (
    tester,
  ) async {
    final tapped = <LocalDate>[];
    await tester.pumpWidget(_app(_october(onDayTap: tapped.add)));

    await tester.tap(_day(12));
    await tester.tap(_day(20));
    await tester.tap(_day(29));
    await tester.tap(_day(30), warnIfMissed: false);

    expect(tapped, [
      LocalDate(2026, 10, 12),
      LocalDate(2026, 10, 20),
      LocalDate(2026, 10, 29),
    ]);
  });

  testWidgets('shows the journal mark only when there is a journal', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_october()));

    expect(
      find.descendant(
        of: _day(12),
        matching: find.byKey(const ValueKey('journal mark')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _day(13),
        matching: find.byKey(const ValueKey('journal mark')),
      ),
      findsNothing,
    );
  });

  testWidgets('reads every day in full words', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(_october(onDayTap: (_) {})));
    final good = moodSemantics(const WholeDayMood(MoodScore.good));

    expect(
      tester.getSemantics(_day(12)),
      isSemantics(
        label: 'Monday, October 12. $good. Journal.',
        isButton: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(_day(29)),
      isSemantics(label: 'Thursday, October 29, today. $good.'),
    );
    expect(
      tester.getSemantics(_day(20)),
      isSemantics(label: 'Tuesday, October 20. No entry.', isButton: true),
    );
    expect(
      tester.getSemantics(_day(30)),
      isSemantics(label: 'Friday, October 30. Not yet.', isButton: false),
    );
    semantics.dispose();
  });

  testWidgets('rings today only', (tester) async {
    await tester.pumpWidget(_app(_october()));
    const colors = LmColors.dawn;
    bool isRing(Widget widget) =>
        widget is DecoratedBox &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
        (widget.decoration as BoxDecoration).border?.top.color ==
            colors.textPrimary;

    expect(find.byWidgetPredicate(isRing), findsOneWidget);
    expect(
      find.descendant(of: _day(29), matching: find.byWidgetPredicate(isRing)),
      findsOneWidget,
    );
  });

  testWidgets('opens the legend from the "?" button', (tester) async {
    await tester.pumpWidget(_app(_october()));

    await tester.tap(find.byTooltip('Calendar legend'));
    await tester.pumpAndSettle();

    expect(find.byType(LmCalendarLegend), findsOneWidget);
    expect(find.text('Journal written'), findsOneWidget);
  });

  testWidgets('fits a 320 px screen at text scale 200 %', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app(_october(onDayTap: (_) {})));

    expect(tester.takeException(), isNull);
  });

  // flutter's built in a11y checks, in both themes
  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name month calendar meets the accessibility guidelines', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(_october(onDayTap: (_) {}), theme: theme));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
