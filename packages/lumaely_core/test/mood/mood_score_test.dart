import 'package:lumaely_core/lumaely_core.dart';
import 'package:test/test.dart';

void main() {
  group('MoodScore.fromValue', () {
    test('mood 1-5', () {
      expect(MoodScore.fromValue(1), MoodScore.rough);
      expect(MoodScore.fromValue(2), MoodScore.low);
      expect(MoodScore.fromValue(3), MoodScore.okay);
      expect(MoodScore.fromValue(4), MoodScore.good);
      expect(MoodScore.fromValue(5), MoodScore.great);
    });

    test('mood oob', () {
      expect(() => MoodScore.fromValue(-1), throwsArgumentError);
      expect(() => MoodScore.fromValue(0), throwsArgumentError);
      expect(() => MoodScore.fromValue(6), throwsArgumentError);
    });
  });
}
