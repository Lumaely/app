import 'package:drift/drift.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_data/src/database/app_database.dart';
import 'package:lumaely_data/src/database/record_ids.dart';
import 'package:lumaely_data/src/database/tables/change_log.dart';

/// Stores the diary's entries in the local database.
///
/// Every write runs in one transaction that also records the change in
/// the changelog.
final class DriftEntryRepository implements EntryRepository {
  new(this._database, this._ids, {this._clock = systemClock});

  final AppDatabase _database;
  final RecordIds _ids;
  final Clock _clock;

  // === writing ===

  @override
  Future<void> save(
    LocalDate date, {
    required DayMoods moods,
    String journal = '',
  }) {
    final now = _clock();
    final entryId = _ids.entry(date);

    return _database.transaction(() async {
      await _saveEntryRow(
        entryId,
        date,
        wholeDay: moods is WholeDayMood,
        journal: journal,
        now: now,
      );
      await _saveMoodRows(entryId, date, _scoresOf(moods), now: now);
    });
  }

  @override
  Future<void> delete(LocalDate date) {
    final now = _clock();
    final entryId = _ids.entry(date);

    return _database.transaction(() async {
      final entry = await _entryRow(entryId);

      if (entry == null || entry.deletedAt != null) {
        return;
      }

      // mark day as deleted (sync)
      await (_database.update(
        _database.entries,
      )..where((row) => row.id.equals(entryId))).write(
        EntriesCompanion(
          journal: const Value(''),
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await _log(_database.entries, entryId, ChangeOp.delete, now);

      for (final mood in await _moodRows(entryId)) {
        if (mood.deletedAt == null) {
          await _deleteMood(mood, now);
        }
      }
    });
  }

  Future<void> _saveEntryRow(
    String id,
    LocalDate date, {
    required bool wholeDay,
    required String journal,
    required DateTime now,
  }) async {
    final existingEntryRow = _aliveEntry(await _entryRow(id));

    if (existingEntryRow != null &&
        existingEntryRow.wholeDay == wholeDay &&
        existingEntryRow.journal == journal) {
      return;
    }

    await _database
        .into(_database.entries)
        .insertOnConflictUpdate(
          // upsert lol
          EntriesCompanion.insert(
            id: id,
            day: date,
            wholeDay: wholeDay,
            journal: Value(journal),
            createdAt: existingEntryRow?.createdAt ?? now,
            updatedAt: now,
            deletedAt: const Value(null),
          ),
        );

    await _log(_database.entries, id, ChangeOp.upsert, now);
  }

  Future<void> _saveMoodRows(
    String entryId,
    LocalDate date,
    Map<String?, int> scores, {
    required DateTime now,
  }) async {
    final toWrite = {
      for (final MapEntry(key: moment, value: score) in scores.entries)
        _ids.mood(date, momentId: moment): (moment: moment, score: score),
    };
    final rows = {for (final row in await _moodRows(entryId)) row.id: row};

    for (final MapEntry(key: id, value: mood) in toWrite.entries) {
      final existingRow = _aliveMood(rows[id]);

      if (existingRow != null && existingRow.score == mood.score) {
        continue;
      }

      await _database
          .into(_database.entryMoods)
          .insertOnConflictUpdate(
            EntryMoodsCompanion.insert(
              id: id,
              entryId: entryId,
              moment: Value(mood.moment),
              score: mood.score,
              createdAt: existingRow?.createdAt ?? now,
              updatedAt: now,
              deletedAt: const Value(null),
            ),
          );

      await _log(_database.entryMoods, id, ChangeOp.upsert, now);
    }

    for (final row in rows.values) {
      final unknownMoment =
          row.moment != null && _knownMoment(row.moment) == null;

      // A moment from a newer app version: not ours to delete.
      if (row.deletedAt != null ||
          toWrite.containsKey(row.id) ||
          unknownMoment) {
        continue;
      }
      await _deleteMood(row, now);
    }
  }

  Future<void> _deleteMood(EntryMoodRow row, DateTime now) async {
    await (_database.update(
      _database.entryMoods,
    )..where((mood) => mood.id.equals(row.id))).write(
      EntryMoodsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );

    await _log(_database.entryMoods, row.id, ChangeOp.delete, now);
  }

  /// The scores to store, by moment id (null for the whole day).
  static Map<String?, int> _scoresOf(DayMoods moods) => switch (moods) {
    WholeDayMood(:final score) => {null: score.value},
    MomentMoods(:final scores) => {
      for (final MapEntry(key: moment, value: score) in scores.entries)
        moment.id: score.value,
    },
  };

  /// [row] if it exists and is not deleted, otherwise null.
  static EntryRow? _aliveEntry(EntryRow? row) =>
      row != null && row.deletedAt == null ? row : null;

  /// [row] if it exists and is not deleted, otherwise null.
  static EntryMoodRow? _aliveMood(EntryMoodRow? row) =>
      row != null && row.deletedAt == null ? row : null;

  Future<EntryRow?> _entryRow(String id) => (_database.select(
    _database.entries,
  )..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<List<EntryMoodRow>> _moodRows(String entryId) => (_database.select(
    _database.entryMoods,
  )..where((row) => row.entryId.equals(entryId))).get();

  Future<void> _log(
    TableInfo<Table, Object?> table,
    String id,
    ChangeOp op,
    DateTime now,
  ) => _database
      .into(_database.changeLog)
      .insert(
        ChangeLogCompanion.insert(
          entity: table.actualTableName,
          entityId: id,
          op: op,
          at: now,
        ),
      );

  // === reading ===

  @override
  Stream<DayEntry?> watchDay(LocalDate date) =>
      _watchEntries((entries) => entries.day.equalsValue(date))
          .map((list) => list.isEmpty ? null : list.single)
          .distinct();

  @override
  Stream<List<DayEntry>> watchRange(LocalDate from, LocalDate to) =>
      _watchEntries(
        (entries) =>
            entries.day.isBetweenValues(from.toString(), to.toString()),
      );

  /// The live entries matching [where], oldest first, with their live moods.
  Stream<List<DayEntry>> _watchEntries(
    Expression<bool> Function($EntriesTable entries) where,
  ) {
    final entries = _database.entries;
    final moods = _database.entryMoods;

    final query =
        _database.select(entries).join([
            leftOuterJoin(
              moods,
              moods.entryId.equalsExp(entries.id) & moods.deletedAt.isNull(),
            ),
          ])
          ..where(where(entries) & entries.deletedAt.isNull())
          ..orderBy([OrderingTerm.asc(entries.day)]);

    return query.watch().map(_toDayEntries);
  }

  /// Groups the joined rows by day, then turns each day into a [DayEntry].
  List<DayEntry> _toDayEntries(List<TypedResult> rows) {
    final entryRows = <String, EntryRow>{};
    final moodRows = <String, List<EntryMoodRow>>{};

    for (final row in rows) {
      final entry = row.readTable(_database.entries);
      entryRows[entry.id] = entry;
      moodRows.putIfAbsent(entry.id, () => []);

      final mood = row.readTableOrNull(_database.entryMoods);
      if (mood != null) moodRows[entry.id]!.add(mood);
    }

    final dayEntries = <DayEntry>[];
    for (final entry in entryRows.values) {
      final dayEntry = _toDayEntry(entry, moodRows[entry.id]!);
      if (dayEntry != null) dayEntries.add(dayEntry);
    }
    return dayEntries;
  }

  /// Turns one day's rows into a [DayEntry], or null if its moods don't match
  /// its mode yet (possible for a moment while sync catches up).
  static DayEntry? _toDayEntry(EntryRow entry, List<EntryMoodRow> moods) {
    final dayMoods = entry.wholeDay
        ? _wholeDayMoodOf(moods)
        : _momentMoodsOf(moods);
    if (dayMoods == null) return null;

    // Only changed rows get a new date, so the day changed at its latest row.
    var updatedAt = entry.updatedAt;
    for (final mood in moods) {
      if (mood.updatedAt.isAfter(updatedAt)) updatedAt = mood.updatedAt;
    }

    return DayEntry(
      id: entry.id,
      date: entry.day,
      moods: dayMoods,
      journal: entry.journal,
      createdAt: entry.createdAt.toUtc(),
      updatedAt: updatedAt.toUtc(),
    );
  }

  static DayMoods? _wholeDayMoodOf(List<EntryMoodRow> moods) {
    for (final mood in moods) {
      if (mood.moment == null) {
        return WholeDayMood(MoodScore.fromValue(mood.score));
      }
    }
    return null;
  }

  static DayMoods? _momentMoodsOf(List<EntryMoodRow> moods) {
    final scores = <Moment, MoodScore>{};
    for (final mood in moods) {
      final moment = _knownMoment(mood.moment);
      if (moment != null) scores[moment] = MoodScore.fromValue(mood.score);
    }
    return scores.isEmpty ? null : MomentMoods(scores);
  }

  /// The [Moment] stored as [id], or null for the whole day or for a moment
  /// this app version doesn't know.
  static Moment? _knownMoment(String? id) {
    for (final moment in Moment.values) {
      if (moment.id == id) return moment;
    }
    return null;
  }
}
