import 'package:lumaely_core/src/entry/day_entry.dart';
import 'package:lumaely_core/src/mood/day_moods.dart';
import 'package:lumaely_core/src/time/local_date.dart';

/// Reads and writes the diary's day entries.
abstract interface class EntryRepository {
  /// The entry for [date], or null if there is none.
  /// Emits again after every change to it.
  Stream<DayEntry?> watchDay(LocalDate date);

  /// The entries from [from] to [to] included, from oldest to newest.
  /// Emits again after every change to them.
  Stream<List<DayEntry>> watchRange(LocalDate from, LocalDate to);

  /// Creates the entry for [date], or replaces its moods and journal.
  Future<void> save(
    LocalDate date, {
    required DayMoods moods,
    String journal = '',
  });

  /// Deletes the entry for [date]. Does nothing if there is none.
  Future<void> delete(LocalDate date);
}
