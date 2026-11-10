import 'package:lumaely_core/src/mood/day_moods.dart';
import 'package:lumaely_core/src/time/local_date.dart';
import 'package:meta/meta.dart';

/// What the user recorded for one day. There is at most one per date.
@immutable
final class DayEntry {
  const new({
    required this.id,
    required this.date,
    required this.moods,
    required this.journal,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique ID of the entry
  final String id;

  /// The day of the entry
  final LocalDate date;

  /// Moods of the entry
  final DayMoods moods;

  /// The journal text
  final String journal;

  /// When the entry was first saved, in UTC
  final DateTime createdAt;

  /// When the entry was last saved, in UTC
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      other is DayEntry &&
          other.id == id &&
          other.date == date &&
          other.moods == moods &&
          other.journal == journal &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(id, date, moods, journal, createdAt, updatedAt);
}
