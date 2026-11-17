import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

MomentMoods _moments(List<MoodScore> scores) {
  return MomentMoods({
    for (final (index, score) in scores.indexed) Moment.values[index]: score,
  });
}

void main() {
  final good = moodLabel(MoodScore.good);
  final okay = moodLabel(MoodScore.okay);

  group('moodOfAverage', () {
    test('rounds half up', () {
      expect(moodOfAverage(3.5), MoodScore.good);
      expect(moodOfAverage(3.4), MoodScore.okay);
    });

    test('uses the shown value, so text and word agree', () {
      // 3.25 is shown "3.3": Okay, not Good
      expect(shownAverage(3.25), 3.3);
      expect(moodOfAverage(3.25), MoodScore.okay);
      // 3.45 is shown "3.5": Good
      expect(moodOfAverage(3.45), MoodScore.good);
    });
  });

  group('moodLine', () {
    test('whole day: score and word', () {
      expect(moodLine(const WholeDayMood(MoodScore.good)), '4/5 · $good');
    });

    test('moments: one decimal average, word and count', () {
      final moods = _moments([MoodScore.good, MoodScore.good, MoodScore.okay]);
      expect(moodLine(moods), '3.7/5 · $good · 3 moments');
    });

    test('drops ".0" from a round average', () {
      final moods = _moments([MoodScore.great, MoodScore.okay]);
      expect(moodLine(moods), '4/5 · $good · 2 moments');
    });

    test('says "moment" for one moment', () {
      expect(moodLine(_moments([MoodScore.okay])), '3/5 · $okay · 1 moment');
    });
  });

  group('moodSemantics', () {
    test('reads "of 5" instead of "/5"', () {
      expect(
        moodSemantics(const WholeDayMood(MoodScore.good)),
        '$good, 4 of 5',
      );

      final moods = _moments([
        MoodScore.great,
        MoodScore.good,
        MoodScore.okay,
        MoodScore.low,
      ]);
      expect(moodSemantics(moods), '$good, 3.5 of 5. 4 moments');
    });
  });

  group('LmMoodColors', () {
    const colors = LmColors.dawn;

    test('a round average is the mood color', () {
      for (final score in MoodScore.values) {
        expect(colors.moodAverage(score.value.toDouble()), colors.mood(score));
      }
    });

    test('an average blends the two moods around it', () {
      expect(
        colors.moodAverage(3.5),
        Color.lerp(
          colors.mood(MoodScore.okay),
          colors.mood(MoodScore.good),
          .5,
        ),
      );
    });

    test('outlines only rough and great', () {
      expect(colors.moodOutline(MoodScore.rough), colors.mood1Outline);
      expect(colors.moodOutline(MoodScore.great), colors.border);
      for (final score in [MoodScore.low, MoodScore.okay, MoodScore.good]) {
        expect(colors.moodOutline(score), isNull, reason: score.name);
      }
    });
  });
}
