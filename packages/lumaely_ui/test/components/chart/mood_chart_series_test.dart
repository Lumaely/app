import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/chart/mood_chart_series.dart';

LocalDate _oct(int day) => LocalDate(2026, 10, day);

void main() {
  group('which smoothings fit', () {
    test('each smoothing needs its minimum number of days', () {
      for (final smoothing in LmMoodChartSmoothing.values) {
        final days = smoothing.minDays;
        expect(
          LmMoodChartSmoothing.availableFor(days),
          contains(smoothing),
          reason: '${smoothing.name} at $days days',
        );
        expect(
          LmMoodChartSmoothing.availableFor(days - 1),
          isNot(contains(smoothing)),
          reason: '${smoothing.name} at ${days - 1} days',
        );
      }
    });

    test('no monthly or weekly over a week', () {
      expect(LmMoodChartSmoothing.availableFor(7), [LmMoodChartSmoothing.none]);
    });

    test('auto smooths more as the period grows', () {
      expect(LmMoodChartSmoothing.autoFor(31), LmMoodChartSmoothing.none);
      expect(
        LmMoodChartSmoothing.autoFor(32),
        LmMoodChartSmoothing.rollingWeek,
      );
      expect(
        LmMoodChartSmoothing.autoFor(92),
        LmMoodChartSmoothing.rollingWeek,
      );
      expect(LmMoodChartSmoothing.autoFor(93), LmMoodChartSmoothing.weekly);
      expect(LmMoodChartSmoothing.autoFor(366), LmMoodChartSmoothing.weekly);
      expect(LmMoodChartSmoothing.autoFor(367), LmMoodChartSmoothing.monthly);
    });

    test('auto always picks a smoothing that fits', () {
      for (var days = 1; days <= 800; days++) {
        expect(
          LmMoodChartSmoothing.availableFor(days),
          contains(LmMoodChartSmoothing.autoFor(days)),
          reason: '$days days',
        );
      }
    });
  });

  group('per day', () {
    test('cuts the line where a day is missing', () {
      final lines = moodChartLines(
        from: _oct(1),
        to: _oct(5),
        moods: {_oct(1): 4, _oct(2): 3.5, _oct(4): 5},
      );

      expect(lines, [
        [const MoodChartPoint(0, 4), const MoodChartPoint(1, 3.5)],
        [const MoodChartPoint(3, 5)],
      ]);
    });

    test('ignores days outside the period', () {
      final lines = moodChartLines(
        from: _oct(2),
        to: _oct(3),
        moods: {_oct(1): 1, _oct(2): 2, _oct(3): 3, _oct(4): 4},
      );

      expect(lines, [
        [const MoodChartPoint(0, 2), const MoodChartPoint(1, 3)],
      ]);
    });

    test('has no line without any day', () {
      expect(moodChartLines(from: _oct(1), to: _oct(31), moods: {}), isEmpty);
    });
  });

  group('7 day rolling average', () {
    test('averages the days written in the 7 days up to each day', () {
      final lines = moodChartLines(
        from: _oct(10),
        to: _oct(11),
        // oct 4 is 7 days before oct 10, oct 3 is not
        moods: {_oct(3): 1, _oct(4): 2, _oct(10): 4, _oct(11): 5},
        smoothing: LmMoodChartSmoothing.rollingWeek,
      );

      expect(lines, [
        [
          const MoodChartPoint(0, (2 + 4) / 2),
          // oct 4 left the window on oct 11
          const MoodChartPoint(1, (4 + 5) / 2),
        ],
      ]);
    });

    test('bridges short gaps, cuts after 7 empty days', () {
      final lines = moodChartLines(
        from: _oct(1),
        to: _oct(10),
        moods: {_oct(1): 3},
        smoothing: LmMoodChartSmoothing.rollingWeek,
      );

      // oct 1 to 7 still see oct 1, oct 8 to 10 don't
      expect(lines, hasLength(1));
      expect(lines.single, hasLength(7));
    });
  });

  group('per week', () {
    test('one point per week, in the middle of its days in the period', () {
      // oct 1 2026 is a thursday: the first week is cut to oct 1-4
      final lines = moodChartLines(
        from: _oct(1),
        to: _oct(11),
        moods: {_oct(1): 2, _oct(4): 4, _oct(5): 5, _oct(11): 3},
        smoothing: LmMoodChartSmoothing.weekly,
      );

      expect(lines, [
        [
          const MoodChartPoint((0 + 3) / 2, 3),
          const MoodChartPoint((4 + 10) / 2, 4),
        ],
      ]);
    });

    test('cuts the line on a week without any day', () {
      final lines = moodChartLines(
        from: _oct(5),
        to: _oct(25),
        moods: {_oct(5): 4, _oct(19): 4},
        smoothing: LmMoodChartSmoothing.weekly,
      );

      expect(lines, hasLength(2));
    });
  });

  group('per month', () {
    test('one point per month, cut at the ends of the period', () {
      final lines = moodChartLines(
        from: _oct(15),
        to: LocalDate(2026, 12, 10),
        moods: {
          _oct(20): 4,
          LocalDate(2026, 11, 2): 2,
          LocalDate(2026, 11, 3): 3,
          LocalDate(2026, 12, 1): 5,
        },
        smoothing: LmMoodChartSmoothing.monthly,
      );

      // oct 15-31 = days 0-16, nov = 17-46, dec 1-10 = 47-56
      expect(lines, [
        [
          const MoodChartPoint(8, 4),
          const MoodChartPoint(31.5, 2.5),
          const MoodChartPoint(51.5, 5),
        ],
      ]);
    });

    test('goes from december to january', () {
      final lines = moodChartLines(
        from: LocalDate(2026, 12, 1),
        to: LocalDate(2027, 1, 31),
        moods: {LocalDate(2026, 12, 24): 4, LocalDate(2027, 1, 1): 5},
        smoothing: LmMoodChartSmoothing.monthly,
      );

      expect(lines.single.map((point) => point.mood), [4, 5]);
    });
  });
}
