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
  });

  factory fromEntry(DayEntry? entry) {
    final moods = entry?.moods;

    return EntryDraft(
      wholeDay: moods is WholeDayMood,
      dayScore: moods is WholeDayMood ? moods.score : null,
      momentScores: moods is MomentMoods ? moods.scores : const {},
      journal: entry?.journal ?? '',
      savedMoods: moods,
    );
  }

  /// true if mode is "whole day", false if it's moments mode
  final bool wholeDay;

  final MoodScore? dayScore;
  final Map<Moment, MoodScore> momentScores;
  final String journal;

  /// The moods in the diary, null if the day isn't written yet
  final DayMoods? savedMoods;

  /// The moods of the current mode, null while there is none.
  DayMoods? get moods {
    if (wholeDay) {
      final score = dayScore;

      return score == null ? null : WholeDayMood(score);
    }

    return momentScores.isEmpty ? null : MomentMoods(momentScores);
  }

  /// Whether leaving now would lose something
  bool get hasChanges {
    final moods = this.moods;

    return moods != null && moods != savedMoods;
  }

  EntryDraft copyWith({
    bool? wholeDay,
    MoodScore? dayScore,
    Map<Moment, MoodScore>? momentScores,
    DayMoods? savedMoods,
  }) {
    return EntryDraft(
      wholeDay: wholeDay ?? this.wholeDay,
      dayScore: dayScore ?? this.dayScore,
      momentScores: momentScores ?? this.momentScores,
      journal: journal,
      savedMoods: savedMoods ?? this.savedMoods,
    );
  }
}
