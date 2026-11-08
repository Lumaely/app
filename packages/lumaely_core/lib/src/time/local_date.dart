import 'package:meta/meta.dart';

/// A calendar day as the person lived it, with no time and no time zone.
///
/// Stored as `YYYY-MM-DD`. Two entries on "Oct 29" are the same day
/// wherever the phone was.
@immutable
final class LocalDate implements Comparable<LocalDate> {
  /// Creates a date, or throws if it does not exist (e.g. Feb 30).
  new(this.year, this.month, this.day) {
    final check = DateTime.utc(year, month, day);

    if (check.year != year || check.month != month || check.day != day) {
      throw ArgumentError('Invalid date: $year-$month-$day');
    }
  }

  /// The day shown by [dateTime] in its own time zone.
  factory fromDateTime(DateTime dateTime) =>
      LocalDate(dateTime.year, dateTime.month, dateTime.day);

  /// Parses `YYYY-MM-DD`, the format stored in the database.
  factory parse(String text) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
    if (match == null) {
      throw FormatException('Expected YYYY-MM-DD', text);
    }
    return LocalDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  final int year;
  final int month;
  final int day;

  /// The date [days] later (or earlier if negative).
  LocalDate addDays(int days) {
    final moved = _asUtc.add(Duration(days: days));
    return LocalDate(moved.year, moved.month, moved.day);
  }

  /// Whole days from [other] to this date.
  int daysSince(LocalDate other) => _asUtc.difference(other._asUtc).inDays;

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  DateTime get _asUtc => DateTime.utc(year, month, day);

  @override
  int compareTo(LocalDate other) => _asUtc.compareTo(other._asUtc);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// `YYYY-MM-DD`.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
