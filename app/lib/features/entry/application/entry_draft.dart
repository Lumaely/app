import 'package:flutter/foundation.dart';
import 'package:lumaely_core/lumaely_core.dart';

/// A day being written, before it's saved.
///
/// - keeps the moods of both modes: switching back and forth loses nothing
/// - only the current mode is saved ([moods])
@immutable
final class EntryDraft {
  const new({
    this.wholeDay = false,
    this.dayScore,
    this.momentScores = const {},
    this.journal = '',
    this.savedMoods,
    this.savedJournal = '',
  });

  factory fromEntry(DayEntry? entry) {
    final moods = entry?.moods;

    return EntryDraft(
      wholeDay: moods is WholeDayMood,
      dayScore: moods is WholeDayMood ? moods.score : null,
      momentScores: moods is MomentMoods ? moods.scores : const {},
      journal: entry?.journal ?? '',
      savedMoods: moods,
      savedJournal: entry?.journal ?? '',
    );
  }

  /// true if mode is "whole day", false if it's moments mode
  final bool wholeDay;

  final MoodScore? dayScore;
  final Map<Moment, MoodScore> momentScores;

  /// The text as typed, see [journalText]
  final String journal;

  /// The moods in the diary, null if the day isn't written yet
  final DayMoods? savedMoods;

  /// The text in the diary
  final String savedJournal;

  /// The moods of the current mode, null while there is none.
  DayMoods? get moods {
    if (wholeDay) {
      final score = dayScore;

      return score == null ? null : WholeDayMood(score);
    }

    return momentScores.isEmpty ? null : MomentMoods(momentScores);
  }

  /// The text to save, without the spaces around it
  String get journalText => journal.trim();

  bool get hasMoodChanges {
    final moods = this.moods;

    return moods != null && moods != savedMoods;
  }

  bool get hasJournalChanges => journalText != savedJournal.trim();

  /// Whether leaving now would lose something
  bool get hasChanges => hasMoodChanges || hasJournalChanges;

  EntryDraft copyWith({
    bool? wholeDay,
    MoodScore? dayScore,
    Map<Moment, MoodScore>? momentScores,
    String? journal,
    DayMoods? savedMoods,
    String? savedJournal,
  }) {
    return EntryDraft(
      wholeDay: wholeDay ?? this.wholeDay,
      dayScore: dayScore ?? this.dayScore,
      momentScores: momentScores ?? this.momentScores,
      journal: journal ?? this.journal,
      savedMoods: savedMoods ?? this.savedMoods,
      savedJournal: savedJournal ?? this.savedJournal,
    );
  }
}
