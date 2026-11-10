import 'package:lumaely_core/src/mood/moment.dart';
import 'package:lumaely_core/src/mood/mood_score.dart';
import 'package:meta/meta.dart';

/// The moods of one day: one for the whole day ([WholeDayMood]), or one per
/// moment ([MomentMoods]).
@immutable
sealed class DayMoods {
  const new();

  /// The mean of these moods, from 1 to 5.
  double get average;
}

/// One mood for the whole day.
final class WholeDayMood extends DayMoods {
  const new(this.score);

  final MoodScore score;

  @override
  double get average => score.value.toDouble();

  @override
  bool operator ==(Object other) =>
      other is WholeDayMood && other.score == score;

  @override
  int get hashCode => score.hashCode;
}

/// One mood per moment, for the moments the person filled in.
final class MomentMoods extends DayMoods {
  /// Throws if [scores] is empty: a day needs at least one mood.
  new(Map<Moment, MoodScore> scores)
    : scores = Map.unmodifiable({
        for (final moment in Moment.values) moment: ?scores[moment],
      }) {
    if (scores.isEmpty) {
      throw ArgumentError.value(scores, 'scores', 'Needs at least one moment');
    }
  }

  /// The moods by moment, always in the order of the day.
  final Map<Moment, MoodScore> scores;

  @override
  double get average =>
      scores.values.fold(0, (sum, score) => sum + score.value) / scores.length;

  @override
  bool operator ==(Object other) =>
      other is MomentMoods &&
      other.scores.length == scores.length &&
      scores.entries.every((entry) => other.scores[entry.key] == entry.value);

  @override
  int get hashCode => Object.hashAll(
    scores.entries.map((entry) => Object.hash(entry.key, entry.value)),
  );
}
