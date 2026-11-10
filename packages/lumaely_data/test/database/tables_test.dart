import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:lumaely_data/src/database/tables/change_log.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;
import 'package:test/test.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.inMemory());
  tearDown(() => database.close());

  final day = LocalDate(2026, 11, 10);
  final savedAt = DateTime.utc(2026, 11, 10, 21, 30, 15, 123);

  Future<void> insertEntry(String id, LocalDate day) => database
      .into(database.entries)
      .insert(
        EntriesCompanion.insert(
          id: id,
          day: day,
          wholeDay: false,
          createdAt: savedAt,
          updatedAt: savedAt,
        ),
      );

  Future<void> insertMood(
    String id, {
    required String entryId,
    String? moment,
    int score = 4,
  }) => database
      .into(database.entryMoods)
      .insert(
        EntryMoodsCompanion.insert(
          id: id,
          entryId: entryId,
          moment: Value(moment),
          score: score,
          createdAt: savedAt,
          updatedAt: savedAt,
        ),
      );

  test('reads back the day and the exact save time', () async {
    await insertEntry('entry', day);

    final row = await database.select(database.entries).getSingle();

    expect(row.day, day);
    expect(row.createdAt.toUtc(), savedAt);
    expect(row.journal, isEmpty);
    expect(row.serverVersion, 0);
    expect(row.deletedAt, isNull);
  });

  test('keeps one row per day', () async {
    await insertEntry('first', day);

    await expectLater(
      insertEntry('second', day),
      throwsA(isA<SqliteException>()),
    );
  });

  test('refuses a score outside 1 to 5', () async {
    await insertEntry('entry', day);

    await expectLater(
      insertMood('mood', entryId: 'entry', score: 6),
      throwsA(isA<SqliteException>()),
    );
  });

  test('refuses a mood without its entry', () async {
    await expectLater(
      insertMood('mood', entryId: 'missing'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('keeps one mood per moment', () async {
    await insertEntry('entry', day);
    await insertMood('first', entryId: 'entry', moment: Moment.morning.id);

    await expectLater(
      insertMood('second', entryId: 'entry', moment: Moment.morning.id),
      throwsA(isA<SqliteException>()),
    );
  });

  test('records changes in order', () async {
    for (final op in [ChangeOp.upsert, ChangeOp.delete]) {
      await database
          .into(database.changeLog)
          .insert(
            ChangeLogCompanion.insert(
              entity: 'entries',
              entityId: 'entry',
              op: op,
              at: savedAt,
            ),
          );
    }

    final rows = await (database.select(
      database.changeLog,
    )..orderBy([(row) => OrderingTerm(expression: row.seq)])).get();

    expect(rows.map((row) => row.op), [ChangeOp.upsert, ChangeOp.delete]);
    expect(rows.first.seq, lessThan(rows.last.seq));
  });
}
