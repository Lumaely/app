import 'package:lumaely_core/lumaely_core.dart';
import 'package:test/test.dart';

void main() {
  final today = LocalDate(2026, 3, 2);

  // days are given by how long ago they are: 0 = today, 1 = yesterday
  int streak(Iterable<int> daysAgo) => streakOf({
    for (final days in daysAgo) today.addDays(-days),
  }, today: today);

  test('nothing written: no streak', () {
    expect(streak([]), 0);
  });

  test('counts the days in a row up to today', () {
    expect(streak([0]), 1);
    expect(streak([0, 1, 2]), 3);
  });

  test('today not written yet: the streak still stands', () {
    expect(streak([1, 2]), 2);
  });

  test('yesterday and today missed: the streak is over', () {
    expect(streak([2, 3, 4]), 0);
  });

  test('stops at the first missing day', () {
    expect(streak([0, 1, 3, 4, 5]), 2);
    expect(streak([0, 2, 3]), 1);
  });

  test('a past day written late joins the days around it', () {
    expect(streak([0, 2]), 1);
    expect(streak([0, 1, 2]), 3);
  });

  test('days after today do not count', () {
    expect(streak([-1]), 0);
    expect(streak([-1, 0, 1]), 2);
  });

  test('goes through months, leap days and years', () {
    final written = {
      for (
        var day = LocalDate(2027, 12, 30);
        !day.isAfter(LocalDate(2028, 3, 1));
        day = day.addDays(1)
      )
        day,
    };

    // 2 in december, 31 in january, 29 in february, 1 in march
    expect(streakOf(written, today: LocalDate(2028, 3, 1)), 63);
  });
}
