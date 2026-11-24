import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/data/entries/entry_providers.dart';
import 'package:lumaely/features/entry/application/entry_editor.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_data/lumaely_data.dart';

import '../../helpers/test_diary.dart';

// on a real diary: the rows really are written and read back
void main() {
  late LocalDiary diary;

  setUpAll(() async => diary = await createTestDiary());

  final date = LocalDate(2026, 10, 29);
  tearDown(() => diary.entries.delete(date));

  Future<EntryEditor> openEditor() async {
    final container = ProviderContainer.test(
      overrides: [entryRepositoryProvider.overrideWithValue(diary.entries)],
    );
    final provider = entryEditorProvider(date);
    container.listen(provider, (_, _) {});
    await container.read(provider.future);
    final editor = container.read(provider.notifier);
    return editor;
  }

  Future<DayEntry?> saved() => diary.entries.watchDay(date).first;

  test('saves the filled moments only', () async {
    final editor = await openEditor();

    editor
      ..setMomentScore(Moment.morning, MoodScore.good)
      ..setMomentScore(Moment.night, MoodScore.low);
    await editor.saveMoods();

    expect(
      (await saved())!.moods,
      MomentMoods(const {
        Moment.morning: MoodScore.good,
        Moment.night: MoodScore.low,
      }),
    );
    expect(editor.state.requireValue.hasChanges, isFalse);
  });

  test('saves the mode shown, the other one is dropped', () async {
    final editor = await openEditor();

    editor.setMomentScore(Moment.morning, MoodScore.good);
    await editor.saveMoods();
    editor
      ..switchMode()
      ..setDayScore(MoodScore.great);
    await editor.saveMoods();

    expect((await saved())!.moods, const WholeDayMood(MoodScore.great));
  });

  test('keeps the journal already written', () async {
    await diary.entries.save(
      date,
      moods: const WholeDayMood(MoodScore.okay),
      journal: 'Long walk',
    );
    final editor = await openEditor();

    editor.setDayScore(MoodScore.good);
    await editor.saveMoods();

    final entry = (await saved())!;
    expect(entry.moods, const WholeDayMood(MoodScore.good));
    expect(entry.journal, 'Long walk');
  });

  test('saves the journal, without the spaces around it', () async {
    final editor = await openEditor();

    editor
      ..switchMode()
      ..setDayScore(MoodScore.good);
    await editor.saveMoods();
    editor.setJournal('  Long walk\n');
    await editor.saveJournal();

    final entry = (await saved())!;
    expect(entry.moods, const WholeDayMood(MoodScore.good));
    expect(entry.journal, 'Long walk');
    expect(editor.state.requireValue.hasChanges, isFalse);
  });

  test('an emptied journal is erased', () async {
    await diary.entries.save(
      date,
      moods: const WholeDayMood(MoodScore.okay),
      journal: 'Long walk',
    );
    final editor = await openEditor();

    editor.setJournal('');
    await editor.saveJournal();

    expect((await saved())!.journal, isEmpty);
  });

  test('saving the moods leaves the text being written alone', () async {
    final editor = await openEditor();

    editor
      ..switchMode()
      ..setDayScore(MoodScore.good);
    await editor.saveMoods();
    editor
      ..setJournal('Long walk')
      ..setDayScore(MoodScore.low);
    await editor.saveMoods();

    expect((await saved())!.journal, isEmpty);
    expect(editor.state.requireValue.journal, 'Long walk');
    expect(editor.state.requireValue.hasJournalChanges, isTrue);
  });

  test('no journal without moods', () async {
    final editor = await openEditor();

    editor.setJournal('Long walk');

    await expectLater(editor.saveJournal(), throwsStateError);
    expect(await saved(), isNull);
  });

  test('nothing to save without a mood', () async {
    final editor = await openEditor();

    await expectLater(editor.saveMoods(), throwsStateError);
    expect(await saved(), isNull);
  });
}
