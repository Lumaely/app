import 'package:lumaely_core/src/time/local_date.dart';

/// returns how many days in a row are [written], up to [today] or yesterday.
int streakOf(Set<LocalDate> written, {required LocalDate today}) {
  var day = written.contains(today) ? today : today.addDays(-1);
  var streak = 0;

  while (written.contains(day)) {
    streak++;
    day = day.addDays(-1);
  }

  return streak;
}
