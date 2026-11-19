import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// a believable year of 2026, the same on every rebuild:
// okay january, rough february, slow spring, a happy may-june, no writing
// during a july holiday, stressful september, better autumn
const _phases = [
  // (day of the year, usual mood)
  (0, 3.2), (31, 3.0), (45, 1.8), (70, 2.6), (110, 3.4), (125, 4.4),
  (165, 4.6), (180, 3.8), (240, 3.5), (250, 2.4), (280, 2.6), (300, 3.9),
  (355, 4.4), (365, 4.2),
];

double _usualMood(int day) {
  for (var i = 1; i < _phases.length; i++) {
    final (end, endMood) = _phases[i];
    if (day <= end) {
      final (start, startMood) = _phases[i - 1];
      return startMood + (endMood - startMood) * (day - start) / (end - start);
    }
  }
  return _phases.last.$2;
}

// tiny seeded random (same numbers every time), 0 to 1
double Function() _random(int seed) {
  var state = seed;
  return () {
    state = (state * 1103515245 + 12345) & 0x7fffffff;
    return state / 0x7fffffff;
  };
}

MoodScore _score(double mood) => MoodScore.fromValue(mood.round().clamp(1, 5));

Map<LocalDate, DayEntry> _diary({required bool gaps}) {
  final first = LocalDate(2026, 1, 1);
  final now = DateTime.utc(2026, 12, 31);
  final random = _random(42);
  final entries = <LocalDate, DayEntry>{};
  for (var day = 0; day < 365; day++) {
    final date = first.addDays(day);
    final holiday = day >= 186 && day < 197; // jul 6-16
    final skipped = random() < 0.08;
    if (gaps && (holiday || skipped)) continue;
    final usual = _usualMood(day);
    // some days are written moment by moment, so averages like 3.5 show up
    final byMoment = random() < 0.35;
    final moods = byMoment
        ? MomentMoods({
            for (final moment in [
              Moment.morning,
              Moment.afternoon,
              Moment.evening,
            ])
              moment: _score(usual + (random() - 0.5) * 2.4),
          })
        : WholeDayMood(_score(usual + (random() - 0.5) * 2.2));
    entries[date] = DayEntry(
      id: 'entry-$day',
      date: date,
      moods: moods,
      journal: '',
      createdAt: now,
      updatedAt: now,
    );
  }
  return entries;
}

LocalDate _local(DateTime date) => LocalDate(date.year, date.month, date.day);

@widgetbook.UseCase(name: 'Playground', type: LmMoodChart, path: '[Components]')
Widget moodChartPlayground(BuildContext context) {
  final knobs = context.knobs;
  final period = knobs.object.dropdown(
    label: 'Period',
    options: const [
      '7 days',
      '14 days',
      '29 days',
      '62 days',
      '90 days',
      '365 days',
      'Custom',
    ],
    initialOption: '90 days',
    labelBuilder: (period) => period,
  );
  final customFrom = knobs.dateTime(
    label: 'Custom from',
    initialValue: DateTime(2026, 4, 2),
    start: DateTime(2026),
    end: DateTime(2026, 12, 31),
  );
  final customTo = knobs.dateTime(
    label: 'Custom to',
    initialValue: DateTime(2026, 10, 20),
    start: DateTime(2026),
    end: DateTime(2026, 12, 31),
  );
  final gaps = knobs.boolean(label: 'Days without entry', initialValue: true);

  final end = LocalDate(2026, 12, 31);
  final (from, to) = switch (period) {
    '7 days' => (end.addDays(-6), end),
    '14 days' => (end.addDays(-13), end),
    // too many points for dots on a phone: only where lines start and end
    '62 days' => (end.addDays(-61), end),
    '29 days' => (end.addDays(-28), end),
    '90 days' => (end.addDays(-89), end),
    '365 days' => (end.addDays(-364), end),
    // custom: in either order
    _ =>
      customFrom.isAfter(customTo)
          ? (_local(customTo), _local(customFrom))
          : (_local(customFrom), _local(customTo)),
  };
  // auto, then only what fits the period (no monthly over a week)
  final days = to.daysSince(from) + 1;
  // names, not the enum: widgetbook's dropdown can't hold null for "auto"
  final choice = knobs.object.dropdown(
    label: 'Smoothing',
    options: [
      'auto',
      for (final smoothing in LmMoodChartSmoothing.availableFor(days))
        smoothing.name,
    ],
    labelBuilder: (name) => name,
  );
  // a choice that no longer fits (shorter period) falls back to auto in the
  // chart itself
  final smoothing = choice == 'auto'
      ? LmMoodChartSmoothing.autoFor(days)
      : LmMoodChartSmoothing.values.byName(choice);

  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LmTile(
            child: Padding(
              padding: const EdgeInsets.all(LmSpace.s4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: LmSpace.s3,
                children: [
                  Text(
                    'Mood over time',
                    style: LmTypography.titleSmall.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  LmMoodChart(
                    from: from,
                    to: to,
                    entries: _diary(gaps: gaps),
                    smoothing: smoothing,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
