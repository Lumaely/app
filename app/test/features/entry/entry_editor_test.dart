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
    await editor.save();

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
    await editor.save();
    editor
      ..switchMode()
      ..setDayScore(MoodScore.great);
    await editor.save();

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
    await editor.save();

    final entry = (await saved())!;
    expect(entry.moods, const WholeDayMood(MoodScore.good));
    expect(entry.journal, 'Long walk');
  });

  test('nothing to save without a mood', () async {
    final editor = await openEditor();

    await expectLater(editor.save(), throwsStateError);
    expect(await saved(), isNull);
  });
}
