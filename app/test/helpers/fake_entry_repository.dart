import 'dart:async';

import 'package:lumaely_core/lumaely_core.dart';

/// entries in memory (a real database doesn't run inside testWidgets), live
/// - [readError] / [saveError]: what reading / saving throws, if anything
/// - [saved]: completes the saves, to see what happens meanwhile
class FakeEntryRepository implements EntryRepository {
  final Map<LocalDate, DayEntry> days = {};
  Exception? readError;
  Exception? saveError;
  Future<void>? saved;
  int saves = 0;

  /// the ranges read, one for each watchRange
  final List<(LocalDate, LocalDate)> ranges = [];

  final _changes = StreamController<void>.broadcast();

  // what [read] gives, again after every change
  Stream<T> _live<T>(T Function() read) async* {
    if (readError case final error?) {
      throw error;
    }

    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<DayEntry?> watchDay(LocalDate date) => _live(() => days[date]);

  @override
  Stream<List<DayEntry>> watchRange(LocalDate from, LocalDate to) {
    ranges.add((from, to));

    return _live(
      () => [
        for (final day in days.values)
          if (!day.date.isBefore(from) && !day.date.isAfter(to)) day,
      ],
    );
  }

  @override
  Stream<Set<LocalDate>> watchDates() => _live(() => days.keys.toSet());

  @override
  Future<void> save(
    LocalDate date, {
    required DayMoods moods,
    String journal = '',
  }) async {
    saves++;

    await saved;

    if (saveError case final error?) {
      throw error;
    }

    final now = DateTime.utc(2026);

    days[date] = DayEntry(
      id: '$date',
      date: date,
      moods: moods,
      journal: journal,
      createdAt: now,
      updatedAt: now,
    );
    _changes.add(null);
  }

  @override
  Future<void> delete(LocalDate date) async {
    days.remove(date);
    _changes.add(null);
  }
}
