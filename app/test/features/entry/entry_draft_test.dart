import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/features/entry/application/entry_draft.dart';
import 'package:lumaely_core/lumaely_core.dart';

void main() {
  DayEntry entry(DayMoods moods, {String journal = ''}) => DayEntry(
    id: 'id',
    date: LocalDate(2026, 10, 29),
    moods: moods,
    journal: journal,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('a new day: by moment, nothing to save', () {
    final draft = EntryDraft.fromEntry(null);

    expect(draft.wholeDay, isFalse);
    expect(draft.moods, isNull);
    expect(draft.hasChanges, isFalse);
  });

  test('a saved day keeps its mode, moods and journal', () {
    final moods = [
      const WholeDayMood(MoodScore.good),
      MomentMoods(const {Moment.noon: MoodScore.low}),
    ];

    for (final mood in moods) {
      final draft = EntryDraft.fromEntry(entry(mood, journal: 'Hello'));

      expect(draft.wholeDay, mood is WholeDayMood);
      expect(draft.moods, mood);
      expect(draft.journal, 'Hello');
      expect(draft.hasChanges, isFalse);
    }
  });

  test('switching back and forth keeps the moods of both modes', () {
    final moments = const EntryDraft().copyWith(
      momentScores: {Moment.morning: MoodScore.great},
    );

    final wholeDay = moments.copyWith(wholeDay: true);
    expect(wholeDay.moods, isNull);

    final scored = wholeDay.copyWith(dayScore: MoodScore.low);
    expect(scored.moods, const WholeDayMood(MoodScore.low));

    final back = scored.copyWith(wholeDay: false);
    expect(back.moods, moments.moods);
  });

  test('a change counts until it is saved or undone', () {
    final saved = EntryDraft.fromEntry(
      entry(const WholeDayMood(MoodScore.good)),
    );
    final changed = saved.copyWith(dayScore: MoodScore.low);

    expect(changed.hasChanges, isTrue);
    expect(changed.copyWith(dayScore: MoodScore.good).hasChanges, isFalse);
    expect(changed.copyWith(savedMoods: changed.moods).hasChanges, isFalse);
  });

  test('an empty mode has nothing to lose', () {
    final saved = EntryDraft.fromEntry(
      entry(const WholeDayMood(MoodScore.good)),
    );

    expect(saved.copyWith(wholeDay: false).hasChanges, isFalse);
  });
}
