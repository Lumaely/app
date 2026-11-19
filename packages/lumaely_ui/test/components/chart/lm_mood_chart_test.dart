import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:lumaely_ui/src/components/chart/lm_mood_chart.dart'
    show MoodChartPainter;
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(20), child: child),
    ),
  );
}

DayEntry _entry(LocalDate date, MoodScore score) {
  final now = DateTime.utc(2026, 11, 17);
  return DayEntry(
    id: 'id-$date',
    date: date,
    moods: WholeDayMood(score),
    journal: '',
    createdAt: now,
    updatedAt: now,
  );
}

Map<LocalDate, DayEntry> _days(LocalDate from, int count, MoodScore score) => {
  for (var i = 0; i < count; i++)
    from.addDays(i): _entry(from.addDays(i), score),
};

final _oct1 = LocalDate(2026, 10, 1);
final _oct29 = LocalDate(2026, 10, 29);

void main() {
  final good = moodLabel(MoodScore.good);
  final okay = moodLabel(MoodScore.okay);
  final great = moodLabel(MoodScore.great);

  group('summary', () {
    test('average, lowest, highest and days written', () {
      final entries = {
        _oct1: _entry(_oct1, MoodScore.okay),
        _oct1.addDays(1): _entry(_oct1.addDays(1), MoodScore.great),
        _oct1.addDays(2): _entry(_oct1.addDays(2), MoodScore.good),
      };

      expect(
        moodChartSummary(from: _oct1, to: _oct29, entries: entries),
        'Mood chart, October 1 to 29. Average $good, 4 of 5. '
        'From $okay to $great. 3 days written.',
      );
    });

    test('says when every day has the same mood', () {
      expect(
        moodChartSummary(
          from: _oct1,
          to: _oct29,
          entries: _days(_oct1, 1, MoodScore.good),
        ),
        'Mood chart, October 1 to 29. Average $good, 4 of 5. '
        'All days $good. 1 day written.',
      );
    });

    test('says when nothing was written', () {
      expect(
        moodChartSummary(from: _oct1, to: _oct29, entries: const {}),
        'Mood chart, October 1 to 29. No day written.',
      );
    });

    test('names the smoothing', () {
      expect(
        moodChartSummary(
          from: _oct1,
          to: _oct29,
          entries: _days(_oct1, 3, MoodScore.good),
          smoothing: LmMoodChartSmoothing.rollingWeek,
        ),
        endsWith('Shown as a 7 day average.'),
      );
    });

    test('writes the period in full', () {
      String period(LocalDate from, LocalDate to) =>
          moodChartSummary(from: from, to: to, entries: const {});

      expect(
        period(LocalDate(2026, 10, 15), LocalDate(2026, 11, 14)),
        startsWith('Mood chart, October 15 to November 14.'),
      );
      expect(
        period(LocalDate(2026, 12, 1), LocalDate(2027, 1, 31)),
        startsWith('Mood chart, December 1, 2026 to January 31, 2027.'),
      );
    });

    test('only counts days in the period', () {
      expect(
        moodChartSummary(
          from: _oct1.addDays(5),
          to: _oct29,
          entries: _days(_oct1, 10, MoodScore.good),
        ),
        contains('5 days written'),
      );
    });
  });

  testWidgets('reads as its summary', (tester) async {
    final semantics = tester.ensureSemantics();
    final entries = _days(_oct1, 29, MoodScore.good);
    await tester.pumpWidget(
      _app(LmMoodChart(from: _oct1, to: _oct29, entries: entries)),
    );

    expect(
      tester.getSemantics(find.byType(LmMoodChart)),
      isSemantics(
        label: moodChartSummary(from: _oct1, to: _oct29, entries: entries),
      ),
    );
    semantics.dispose();
  });

  testWidgets('shows 5, 3, 1 and the start, middle and end dates', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(LmMoodChart(from: _oct1, to: _oct29, entries: const {})),
    );

    for (final text in ['5', '3', '1', 'Oct 1', 'Oct 15', 'Oct 29']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  MoodChartPainter painterOf(WidgetTester tester) {
    return tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .firstWhere((paint) => paint.painter is MoodChartPainter)
            .painter!
        as MoodChartPainter;
  }

  // a phone: dots depend on the real width
  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(393, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Finder chartPaint(MoodChartPainter painter) => find.byWidgetPredicate(
    (widget) => widget is CustomPaint && widget.painter == painter,
  );

  bool dotsFit(WidgetTester tester) {
    final painter = painterOf(tester);
    return painter.dotsFit(tester.getSize(chartPaint(painter)).width);
  }

  testWidgets('on a phone, dots only when they do not touch', (tester) async {
    phone(tester);
    final end = LocalDate(2026, 12, 31);
    for (final (days, smoothing, fits) in [
      // figma: a month per day, ~10 px between dots
      (29, LmMoodChartSmoothing.none, true),
      (62, LmMoodChartSmoothing.none, false),
      // auto over a year = per week, 52 points
      (365, LmMoodChartSmoothing.weekly, false),
      (365, LmMoodChartSmoothing.monthly, true),
    ]) {
      final from = end.addDays(1 - days);
      await tester.pumpWidget(
        _app(
          LmMoodChart(
            from: from,
            to: end,
            entries: _days(from, days, MoodScore.good),
            smoothing: smoothing,
          ),
        ),
      );

      expect(dotsFit(tester), fits, reason: '$days days ${smoothing.name}');
    }
  });

  testWidgets('a year in auto on a phone draws only the two end dots', (
    tester,
  ) async {
    phone(tester);
    final from = LocalDate(2026, 1, 1);
    final chart = LmMoodChart(
      from: from,
      to: LocalDate(2026, 12, 31),
      entries: _days(from, 365, MoodScore.good),
      smoothing: LmMoodChartSmoothing.autoFor(365),
    );
    await tester.pumpWidget(_app(chart));

    expect(chart.usedSmoothing, LmMoodChartSmoothing.weekly);
    // one line: start and end, each a ring then a fill
    expect(
      tester.renderObject(chartPaint(painterOf(tester))),
      paintsExactlyCountTimes(#drawCircle, 4),
    );
  });

  testWidgets('without dots, each line keeps its first and last dot', (
    tester,
  ) async {
    phone(tester);
    final from = LocalDate(2026, 8, 1);
    // 40 days, a gap, 40 days: too close for every dot on a phone
    final entries = {
      ..._days(from, 40, MoodScore.good),
      ..._days(from.addDays(45), 40, MoodScore.good),
    };
    await tester.pumpWidget(
      _app(LmMoodChart(from: from, to: from.addDays(84), entries: entries)),
    );

    final painter = painterOf(tester);
    expect(dotsFit(tester), isFalse);
    expect(painter.lines, hasLength(2));
    // 2 lines x (start + end) = 4 dots, each a ring then a fill
    expect(
      tester.renderObject(chartPaint(painter)),
      paintsExactlyCountTimes(#drawCircle, 8),
    );
  });

  testWidgets('falls back to auto when the smoothing does not fit', (
    tester,
  ) async {
    final week = LocalDate(2026, 10, 1);
    final chart = LmMoodChart(
      from: week,
      to: week.addDays(6),
      entries: _days(week, 7, MoodScore.good),
      smoothing: LmMoodChartSmoothing.monthly,
    );
    await tester.pumpWidget(_app(chart));

    expect(chart.usedSmoothing, LmMoodChartSmoothing.none);
    expect(painterOf(tester).lines.single, hasLength(7));
  });

  testWidgets('fits a 320 px screen at text scale 200 %', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      _app(
        LmMoodChart(
          from: _oct1,
          to: _oct29,
          entries: _days(_oct1, 29, MoodScore.good),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    // no room for the middle date
    expect(find.text('Oct 15'), findsNothing);
    expect(find.text('Oct 29'), findsOneWidget);
  });

  // text contrast of the labels, in both themes
  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name mood chart meets the text contrast guideline', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          LmTile(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LmMoodChart(
                from: _oct1,
                to: _oct29,
                entries: _days(_oct1, 29, MoodScore.good),
              ),
            ),
          ),
          theme: theme,
        ),
      );

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
