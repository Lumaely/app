import 'package:flutter/foundation.dart' show immutable;
import 'package:lumaely_core/lumaely_core.dart';

/// how the mood chart smooths the days
/// - [minDays]: shortest period where it makes sense (no monthly over a week)
/// - [availableFor] lists them
/// - [autoFor] picks one
enum LmMoodChartSmoothing {
  /// one point per day written
  none(1),

  /// each day: average of the 7 days up to it (days written only)
  rollingWeek(14),

  /// one point per week (monday to sunday), at least 4 points
  weekly(28),

  /// one point per month, at least 3 points
  monthly(90);

  new(this.minDays);

  final int minDays;

  /// the smoothings that make sense for a period of [days] days
  static List<LmMoodChartSmoothing> availableFor(int days) => [
    for (final smoothing in values)
      if (days >= smoothing.minDays) smoothing,
  ];

  /// auto (the longer the period, the smoother)
  static LmMoodChartSmoothing autoFor(int days) {
    if (days <= 31) return none;
    if (days <= 92) return rollingWeek;
    if (days <= 366) return weekly;
    return monthly;
  }
}

/// one point of the chart
/// - [day]: days since the start of the period (x), can be half a day for
///   the middle of a week or a month
/// - [mood]: 1-5 (y)
@immutable
final class MoodChartPoint {
  const new(this.day, this.mood);

  final double day;
  final double mood;

  @override
  bool operator ==(Object other) =>
      other is MoodChartPoint && other.day == day && other.mood == mood;

  @override
  int get hashCode => Object.hash(day, mood);

  @override
  String toString() => 'MoodChartPoint($day, $mood)';
}

/// the lines of the chart, from [from] to [to] included
/// - [moods]: average mood of each day written
/// - a new line starts after a gap (a day, week or month with nothing
///   written): a gap has no value, the line must not pretend it has one
List<List<MoodChartPoint>> moodChartLines({
  required LocalDate from,
  required LocalDate to,
  required Map<LocalDate, double> moods,
  LmMoodChartSmoothing smoothing = LmMoodChartSmoothing.none,
}) {
  return switch (smoothing) {
    LmMoodChartSmoothing.none => _byDay(from, to, (day) => moods[day]),
    LmMoodChartSmoothing.rollingWeek => _byDay(
      from,
      to,
      (day) => _average([for (var i = 0; i < 7; i++) ?moods[day.addDays(-i)]]),
    ),
    LmMoodChartSmoothing.weekly => _byBucket(from, to, moods, _mondayOf, 7),
    LmMoodChartSmoothing.monthly => _byBucket(
      from,
      to,
      moods,
      (day) => LocalDate(day.year, day.month, 1),
      null,
    ),
  };
}

// one point per day, cut where [valueOf] is null
List<List<MoodChartPoint>> _byDay(
  LocalDate from,
  LocalDate to,
  double? Function(LocalDate day) valueOf,
) {
  final lines = <List<MoodChartPoint>>[];
  var line = <MoodChartPoint>[];

  for (var day = from; !day.isAfter(to); day = day.addDays(1)) {
    final value = valueOf(day);

    if (value == null) {
      if (line.isNotEmpty) {
        lines.add(line);
      }

      line = [];
    } else {
      line.add(MoodChartPoint(day.daysSince(from).toDouble(), value));
    }
  }

  if (line.isNotEmpty) {
    lines.add(line);
  }

  return lines;
}

// one point per week or month, in the middle of the part inside the period
// - [length] null -> until the end of the month
List<List<MoodChartPoint>> _byBucket(
  LocalDate from,
  LocalDate to,
  Map<LocalDate, double> moods,
  LocalDate Function(LocalDate day) startOf,
  int? length,
) {
  final lines = <List<MoodChartPoint>>[];
  var line = <MoodChartPoint>[];
  var start = startOf(from);

  while (!start.isAfter(to)) {
    final next = length != null
        ? start.addDays(length)
        : LocalDate(
            start.month == 12 ? start.year + 1 : start.year,
            start.month == 12 ? 1 : start.month + 1,
            1,
          );

    final first = start.isBefore(from) ? from : start;
    final last = next.addDays(-1).isAfter(to) ? to : next.addDays(-1);
    final value = _average([
      for (var day = first; !day.isAfter(last); day = day.addDays(1))
        ?moods[day],
    ]);

    if (value == null) {
      if (line.isNotEmpty) {
        lines.add(line);
      }

      line = [];
    } else {
      final middle = (first.daysSince(from) + last.daysSince(from)) / 2;

      line.add(MoodChartPoint(middle, value));
    }

    start = next;
  }

  if (line.isNotEmpty) {
    lines.add(line);
  }

  return lines;
}

double? _average(List<double> values) {
  if (values.isEmpty) {
    return null;
  }

  return values.reduce((a, b) => a + b) / values.length;
}

LocalDate _mondayOf(LocalDate day) {
  final weekday = DateTime(day.year, day.month, day.day).weekday;

  return day.addDays(DateTime.monday - weekday);
}
