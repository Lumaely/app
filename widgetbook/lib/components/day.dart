import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// days as in the journal list
final List<DayEntry> _october = [
  _entry(
    LocalDate(2026, 10, 29),
    MomentMoods(const {
      Moment.morning: MoodScore.good,
      Moment.afternoon: MoodScore.good,
      Moment.evening: MoodScore.okay,
    }),
    'Long walk by the water this morning.',
  ),
  _entry(
    LocalDate(2026, 10, 28),
    const WholeDayMood(MoodScore.okay),
    'Work all day, early night.',
  ),
  _entry(LocalDate(2026, 10, 27), const WholeDayMood(MoodScore.great), ''),
  _entry(
    LocalDate(2026, 10, 26),
    MomentMoods(const {
      Moment.morning: MoodScore.great,
      Moment.noon: MoodScore.good,
      Moment.afternoon: MoodScore.okay,
      Moment.evening: MoodScore.low,
    }),
    'Coffee with friends, then the market.',
  ),
];

DayEntry _entry(LocalDate date, DayMoods moods, String journal) {
  final now = DateTime.utc(2026, 11, 17);
  return DayEntry(
    id: 'entry-$date',
    date: date,
    moods: moods,
    journal: journal,
    createdAt: now,
    updatedAt: now,
  );
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

@widgetbook.UseCase(name: 'All moods', type: LmMoodDot, path: '[Components]')
Widget allMoodDots(BuildContext context) {
  final averages = List<double?>.generate(9, (i) => 1 + .5 * i)
    ..add(null); // 1, 1.5, 2, ..., 5, null

  return _screen(
    Wrap(
      spacing: LmSpace.s4,
      runSpacing: LmSpace.s4,
      direction: .vertical,
      crossAxisAlignment: .center,
      children: [
        for (final average in averages)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: LmSpace.s1,
            children: [
              LmMoodDot(average: average),
              Text(average?.toString() ?? 'empty'),
            ],
          ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Playground', type: LmDayRow, path: '[Components]')
Widget dayRowPlayground(BuildContext context) {
  final knobs = context.knobs;
  final wholeDay = knobs.boolean(label: 'Whole day');
  // e.g. "4,4,3": one score per moment, in the order of the day
  final scores = knobs
      .string(label: 'Scores (1 to 5)', initialValue: '4,4,3')
      .split(',')
      .map((text) => int.tryParse(text.trim()))
      .whereType<int>()
      .where((value) => value >= 1 && value <= 5)
      .map(MoodScore.fromValue)
      .take(Moment.values.length)
      .toList();
  if (scores.isEmpty) {
    scores.add(MoodScore.okay);
  }

  final moods = wholeDay
      ? WholeDayMood(scores.first)
      : MomentMoods({
          for (final (index, score) in scores.indexed)
            Moment.values[index]: score,
        });

  return _screen(
    LmTile(
      child: LmDayRow(
        entry: _entry(
          LocalDate(2026, 10, 29),
          moods,
          knobs.string(
            label: 'Journal',
            initialValue: 'Long walk by the water this morning.',
          ),
        ),
        onTap: knobs.boolean(label: 'Tappable', initialValue: true)
            ? () {}
            : null,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Journal list', type: LmDayRow, path: '[Components]')
Widget journalList(BuildContext context) {
  return _screen(
    LmTileGroup(
      title: 'October 2026',
      titleVariant: LmTileGroupTitleVariant.heading,
      children: [
        for (final entry in _october) LmDayRow(entry: entry, onTap: () {}),
      ],
    ),
  );
}
