import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// fake diary: the same days get the same moods on every rebuild
Map<LocalDate, DayEntry> _entries(int year, int month, int upTo) {
  final now = DateTime.utc(2026, 11, 17);
  return {
    for (var day = 1; day <= upTo; day++)
      if (day % 9 != 0) // a few days without entry
        LocalDate(year, month, day): DayEntry(
          id: 'entry-$day',
          date: LocalDate(year, month, day),
          moods: day.isEven
              ? WholeDayMood(MoodScore.fromValue(day * 7 % 5 + 1))
              : MomentMoods({
                  Moment.morning: MoodScore.fromValue(day % 5 + 1),
                  Moment.evening: MoodScore.fromValue(day * 3 % 5 + 1),
                }),
          journal: day % 3 == 0 ? '' : 'Some words about day $day.',
          createdAt: now,
          updatedAt: now,
        ),
  };
}

Widget _screen(Widget child) {
  return Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: child,
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Playground',
  type: LmMonthCalendar,
  path: '[Components]',
)
Widget monthCalendarPlayground(BuildContext context) {
  final knobs = context.knobs;
  final month = knobs.object.dropdown(
    label: 'Month',
    options: const [(2026, 10), (2027, 2), (2026, 11)],
    labelBuilder: (m) => '${m.$1}-${m.$2}',
  );
  final daysInMonth = DateTime(month.$1, month.$2 + 1, 0).day;
  final todayDay = knobs.int.slider(
    label: 'Today (day)',
    initialValue: 29,
    min: 1,
    max: 31,
  ).clamp(1, daysInMonth);
  final today = LocalDate(month.$1, month.$2, todayDay);

  // the "?" lives in the screen's top bar, once (like the journal screen)
  return Scaffold(
    appBar: AppBar(
      title: const Text('Journal'),
      actions: const [LmCalendarLegendButton()],
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(LmSpace.s4),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LmMonthCalendar(
            year: month.$1,
            month: month.$2,
            entries: _entries(month.$1, month.$2, todayDay),
            today: today,
            onDayTap: (date) =>
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Tapped $date'))),
          ),
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'All states',
  type: LmCalendarDay,
  path: '[Components]',
)
Widget calendarDayStates(BuildContext context) {
  final entries = _entries(2026, 10, 20);
  final cells = [
    ('Journal', LocalDate(2026, 10, 1), true, false),
    ('Mood only', LocalDate(2026, 10, 3), true, false),
    ('Today', LocalDate(2026, 10, 4), true, true),
    ('Today, empty', LocalDate(2026, 10, 9), true, true),
    ('No entry', LocalDate(2026, 10, 18), true, false),
    ('Future', LocalDate(2026, 10, 30), false, false),
  ];
  return _screen(
    Wrap(
      spacing: LmSpace.s4,
      runSpacing: LmSpace.s4,
      children: [
        for (final (label, date, tappable, today) in cells)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: LmSpace.s1,
            children: [
              Text(label, style: LmTypography.bodySmall),
              LmCalendarDay(
                date: date,
                entry: entries[date],
                isToday: today,
                onTap: tappable ? () {} : null,
              ),
            ],
          ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Legend',
  type: LmCalendarLegend,
  path: '[Components]',
)
Widget calendarLegend(BuildContext context) {
  return _screen(const LmCalendarLegend());
}

@widgetbook.UseCase(name: 'Playground', type: LmWeekStrip, path: '[Components]')
Widget weekStripPlayground(BuildContext context) {
  // a week across two months: mon oct 26 to sun nov 1, 2026
  final day = context.knobs.int.slider(
    label: 'Today (0 = monday)',
    initialValue: 3,
    max: 6,
  );
  final today = LocalDate(2026, 10, 26).addDays(day);
  final entries = {..._entries(2026, 10, 31), ..._entries(2026, 11, 1)}
    ..removeWhere((date, _) => date.isAfter(today));

  return _screen(
    LmTile(
      child: Padding(
        padding: const EdgeInsets.all(LmSpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: LmSpace.s3,
          children: [
            Text(
              'This week',
              style: LmTypography.labelMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            LmWeekStrip(
              week: today,
              entries: entries,
              today: today,
              onDayTap: (date) =>
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Tapped $date'))),
            ),
          ],
        ),
      ),
    ),
  );
}
