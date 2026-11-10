import 'package:lumaely_core/lumaely_core.dart';
import 'package:test/test.dart';

void main() {
  group('WholeDayMood', () {
    test('its average is its score', () {
      expect(const WholeDayMood(MoodScore.good).average, 4);
    });
  });

  group('MomentMoods', () {
    test('its average is the mean of its moments', () {
      final moods = MomentMoods(const {
        Moment.morning: MoodScore.great,
        Moment.evening: MoodScore.low,
      });

      expect(moods.average, 3.5);
    });

    test('keeps moments in the order of the day', () {
      final moods = MomentMoods(const {
        Moment.evening: MoodScore.low,
        Moment.morning: MoodScore.great,
        Moment.noon: MoodScore.okay,
      });

      expect(
        moods.scores.keys,
        orderedEquals([Moment.morning, Moment.noon, Moment.evening]),
      );
    });

    test('needs at least one moment', () {
      expect(() => MomentMoods(const {}), throwsArgumentError);
    });

    test('cannot be changed after creation', () {
      final moods = MomentMoods(const { Moment.morning: MoodScore.good });

      expect(
            () => moods.scores[Moment.noon] = MoodScore.low,
        throwsUnsupportedError,
      );
    });

    test('equal moods are equal, whatever their order', () {
      final a = MomentMoods(const {
        Moment.morning: MoodScore.good,
        Moment.evening: MoodScore.low,
      });
      final b = MomentMoods(const {
        Moment.evening: MoodScore.low,
        Moment.morning: MoodScore.good,
      });

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  test('a whole-day mood never equals moment moods', () {
    expect(
      const WholeDayMood(MoodScore.good),
      isNot(equals(MomentMoods(const { Moment.morning: MoodScore.good }))),
    );
  });
}
