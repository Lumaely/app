import 'package:lumaely/data/entries/entry_providers.dart';
import 'package:lumaely/features/entry/application/entry_draft.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entry_editor.g.dart';

/// Editor of entry at date [date] (loads its draft, changes it, saves it)
///
/// The draft lives as long as the entry page --> leaving drops it
@riverpod
class EntryEditor extends _$EntryEditor {
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

  Future<void> save() async {
    final draft = state.requireValue;
    final moods = draft.moods;

    if (moods == null) {
      throw StateError('Nothing to save: no mood yet');
    }

    await ref
        .read(entryRepositoryProvider)
        .save(date, moods: moods, journal: draft.journal);

    if (ref.mounted) {
      _update((draft) => draft.copyWith(savedMoods: moods));
    }
  }

  void _update(EntryDraft Function(EntryDraft draft) change) {
    state = AsyncData(change(state.requireValue));
  }
}
