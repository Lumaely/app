import 'package:lumaely/data/entries/entry_providers.dart';
import 'package:lumaely/features/entry/application/entry_draft.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entry_editor.g.dart';

/// Editor of entry at date [date] (loads its draft, changes it, saves it)
///
/// - the moods and the journal are saved apart: saving the moods again must not
///   save a text that is still being written
/// - the draft lives as long as the entry page --> leaving drops it
@riverpod
class EntryEditor extends _$EntryEditor {
  // FIXME: a text being written is lost if the system closes the app, save it
  // (encrypted) when the app goes to the background?

  @override
  Future<EntryDraft> build(LocalDate date) async {
    final entry = await ref.watch(entryRepositoryProvider).watchDay(date).first;

    return EntryDraft.fromEntry(entry);
  }

  /// one mood for the whole day <-> one per moment
  void switchMode() {
    _update((draft) => draft.copyWith(wholeDay: !draft.wholeDay));
  }

  void setDayScore(MoodScore score) {
    _update((draft) => draft.copyWith(dayScore: score));
  }

  void setMomentScore(Moment moment, MoodScore score) {
    _update(
      (draft) =>
          draft.copyWith(momentScores: {...draft.momentScores, moment: score}),
    );
  }

  void setJournal(String text) {
    _update((draft) => draft.copyWith(journal: text));
  }

  Future<void> saveMoods() async {
    final draft = state.requireValue;
    final moods = draft.moods;

    if (moods == null) {
      throw StateError('Nothing to save: no mood yet');
    }

    await ref
        .read(entryRepositoryProvider)
        .save(date, moods: moods, journal: draft.savedJournal);

    if (ref.mounted) {
      _update((draft) => draft.copyWith(savedMoods: moods));
    }
  }

  /// the moods come first: a day can't be saved without them
  Future<void> saveJournal() async {
    final draft = state.requireValue;
    final moods = draft.savedMoods;
    final text = draft.journalText;

    if (moods == null) {
      throw StateError('Nothing to save: the moods are not saved yet');
    }

    await ref
        .read(entryRepositoryProvider)
        .save(date, moods: moods, journal: text);

    if (ref.mounted) {
      _update((draft) => draft.copyWith(savedJournal: text));
    }
  }

  void _update(EntryDraft Function(EntryDraft draft) change) {
    state = AsyncData(change(state.requireValue));
  }
}
