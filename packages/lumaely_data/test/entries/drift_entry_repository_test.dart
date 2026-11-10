import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:lumaely_data/src/database/record_ids.dart';
import 'package:lumaely_data/src/database/tables/change_log.dart';
import 'package:lumaely_data/src/entries/drift_entry_repository.dart';
import 'package:test/test.dart';

void main() {
  late LmCryptoEngine crypto;
  late AppDatabase database;
  late RecordIds ids;
  late DriftEntryRepository repository;
  late DateTime now;

  final day = LocalDate(2026, 10, 29);

  setUpAll(() async {
    crypto = await LmCryptoEngine.init();
  });

  setUp(() {
    database = AppDatabase.inMemory();
    addTearDown(database.close);

    final master = crypto.generateMasterKey();
    ids = RecordIds.forMasterKey(crypto, master);
    master.dispose();
    addTearDown(ids.dispose);

    now = DateTime.utc(2026, 10, 29, 20);
    repository = DriftEntryRepository(database, ids, clock: () => now);
  });

  Future<EntryRow> entryRow() => database.select(database.entries).getSingle();

  Future<Map<String?, EntryMoodRow>> moodRows() async => {
    for (final row in await database.select(database.entryMoods).get())
      row.moment: row,
  };

  Future<List<ChangeLogRow>> changes() => (database.select(
    database.changeLog,
  )..orderBy([(row) => OrderingTerm(expression: row.seq)])).get();

  void nowButLater() => now = now.add(const Duration(minutes: 5));

  final eveningAndMorning = MomentMoods(const {
    Moment.morning: MoodScore.good,
    Moment.evening: MoodScore.low,
  });

  group('writing', () {
    test('saves a whole-day entry under ids computed from its date', () async {
      await repository.save(
        day,
        moods: const WholeDayMood(MoodScore.good),
        journal: 'shit class',
      );

      final entry = await entryRow();

      expect(entry.id, ids.entry(day));
      expect(entry.wholeDay, isTrue);
      expect(entry.journal, 'shit class');

      final moods = await moodRows();

      expect(moods.keys, [null]);
      expect(moods[null]!.id, ids.mood(day));
      expect(moods[null]!.score, MoodScore.good.value);
    });

    test('saves one row per moment', () async {
      await repository.save(day, moods: eveningAndMorning);

      final moods = await moodRows();

      expect(
        moods.keys,
        unorderedEquals([Moment.morning.id, Moment.evening.id]),
      );
      expect(moods[Moment.evening.id]!.score, MoodScore.low.value);
      expect((await entryRow()).wholeDay, isFalse);
    });

    test('records every write in change_log', () async {
      await repository.save(day, moods: eveningAndMorning);

      final log = await changes();

      expect(log.map((change) => change.entity), [
        'entries',
        'entry_moods',
        'entry_moods',
      ]);

      expect(log.map((change) => change.op), everyElement(ChangeOp.upsert));
    });

    test('saving the same day again writes nothing', () async {
      await repository.save(day, moods: eveningAndMorning);
      final before = await changes();

      nowButLater();

      await repository.save(day, moods: eveningAndMorning);

      expect(await changes(), hasLength(before.length));
      expect((await entryRow()).updatedAt.toUtc(), isNot(now));
    });

    test('changing one moment rewrites only that mood', () async {
      await repository.save(day, moods: eveningAndMorning);
      final savedAt = now;

      nowButLater();

      await repository.save(
        day,
        moods: MomentMoods(const {
          Moment.morning: MoodScore.good,
          Moment.evening: MoodScore.okay,
        }),
      );

      final moods = await moodRows();

      expect(moods[Moment.evening.id]!.updatedAt.toUtc(), now);
      expect(moods[Moment.morning.id]!.updatedAt.toUtc(), savedAt);
    });

    test('switching to a whole-day mood marks the moments deleted', () async {
      await repository.save(day, moods: eveningAndMorning);
      nowButLater();

      await repository.save(day, moods: const WholeDayMood(MoodScore.okay));

      final moods = await moodRows();
      expect(moods[null]!.deletedAt, isNull);
      expect(moods[Moment.morning.id]!.deletedAt?.toUtc(), now);
      expect(moods[Moment.evening.id]!.deletedAt?.toUtc(), now);
      expect((await entryRow()).wholeDay, isTrue);
    });

    test('never deletes a moment from a newer app version', () async {
      await repository.save(day, moods: eveningAndMorning);
      await database
          .into(database.entryMoods)
          .insert(
            EntryMoodsCompanion.insert(
              id: ids.mood(day, momentId: 'siesta'),
              entryId: ids.entry(day),
              moment: const Value('siesta'),
              score: 5,
              createdAt: now,
              updatedAt: now,
            ),
          );
      nowButLater();

      await repository.save(day, moods: const WholeDayMood(MoodScore.okay));

      expect((await moodRows())['siesta']!.deletedAt, isNull);
    });

    test('delete wipes the journal and marks everything deleted', () async {
      await repository.save(day, moods: eveningAndMorning, journal: 'Secret');
      nowButLater();

      await repository.delete(day);

      final entry = await entryRow();

      expect(entry.journal, isEmpty);
      expect(entry.deletedAt?.toUtc(), now);
      expect(
        (await moodRows()).values.map((mood) => mood.deletedAt?.toUtc()),
        everyElement(now),
      );
      expect((await changes()).last.op, ChangeOp.delete);
    });

    test('saving a deleted day brings back the same row', () async {
      await repository.save(day, moods: eveningAndMorning);
      await repository.delete(day);

      nowButLater();

      await repository.save(day, moods: const WholeDayMood(MoodScore.great));

      final entry = await entryRow();

      expect(entry.id, ids.entry(day));
      expect(entry.deletedAt, isNull);
      expect(entry.createdAt.toUtc(), now);
    });
  });

  group('reading', () {
    test('reads back what was saved', () async {
      await repository.save(
        day,
        moods: const WholeDayMood(MoodScore.good),
        journal: 'BONJOUR lol',
      );

      final entry = await repository.watchDay(day).first;

      expect(entry!.id, ids.entry(day));
      expect(entry.date, day);
      expect(entry.moods, const WholeDayMood(MoodScore.good));
      expect(entry.journal, 'BONJOUR lol');
      expect(entry.createdAt, now);
    });

    test('reads moments back in the order of the day', () async {
      await repository.save(day, moods: eveningAndMorning);

      final entry = await repository.watchDay(day).first;

      expect(entry!.moods, eveningAndMorning);
    });

    test('a day with no entry reads as null', () async {
      expect(await repository.watchDay(day).first, isNull);
    });

    test('a deleted day reads as null', () async {
      await repository.save(day, moods: eveningAndMorning);
      await repository.delete(day);

      expect(await repository.watchDay(day).first, isNull);
    });

    test('a day changed when its latest mood changed', () async {
      await repository.save(day, moods: eveningAndMorning);

      nowButLater();

      await repository.save(
        day,
        moods: MomentMoods(const {
          Moment.morning: MoodScore.good,
          Moment.evening: MoodScore.great,
        }),
      );

      final entry = await repository.watchDay(day).first;
      expect(entry!.updatedAt, now);
    });

    test('watchRange gives the days in the range, oldest first', () async {
      for (final date in [day, day.addDays(1), day.addDays(2)]) {
        await repository.save(date, moods: const WholeDayMood(MoodScore.okay));
      }

      final entries = await repository
          .watchRange(day.addDays(1), day.addDays(2))
          .first;

      expect(entries.map((entry) => entry.date), [
        day.addDays(1),
        day.addDays(2),
      ]);
    });

    test('updates by itself after a save', () async {
      final saved = repository
          .watchDay(day)
          .firstWhere((entry) => entry != null);

      await repository.save(day, moods: const WholeDayMood(MoodScore.great));

      expect((await saved)!.moods, const WholeDayMood(MoodScore.great));
    });
  });
}
