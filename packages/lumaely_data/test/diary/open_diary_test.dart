import 'dart:io';
import 'dart:typed_data';

import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:test/test.dart';

import '../support/memory_master_key_cache.dart';

void main() {
  const password = 'hilol';

  late LmCryptoEngine crypto;
  late Directory root;
  late DiaryFiles files;

  setUpAll(() async {
    crypto = await LmCryptoEngine.init();
  });

  setUp(() async {
    root = await Directory.systemTemp.createTemp('lumaely_test__diary_open_');
    files = DiaryFiles(Directory('${root.path}/diary'));
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  /// Creates a diary on "the first phone", closes it, and returns what
  /// the person keeps: the cache of that phone and the recovery key.
  Future<(MemoryMasterKeyCache, RecoveryKey)> createAndClose() async {
    final cache = MemoryMasterKeyCache();
    final created = await LocalDiary.create(
      files: files,
      password: password,
      crypto: crypto,
      cache: cache,
    );
    await created.diary.close();
    return (cache, created.recoveryKey);
  }

  Future<String> storageMode(LocalDiary diary) async {
    final db = diary.database;
    final row = await (db.select(
      db.databaseMeta,
    )..where((meta) => meta.name.equals('storage_mode'))).getSingle();
    return row.value;
  }

  group('openFromCache', () {
    test('opens the diary with the cached key', () async {
      final (cache, _) = await createAndClose();

      final diary = await LocalDiary.openFromCache(
        files: files,
        crypto: crypto,
        cache: cache,
      );
      addTearDown(() => diary?.close());

      expect(diary, isNotNull);
      expect(await storageMode(diary!), 'local_only');
    });

    test('opens the diary with no cached key', () async {
      await createAndClose();

      final diary = await LocalDiary.openFromCache(
        files: files,
        crypto: crypto,
        cache: MemoryMasterKeyCache(),
      );

      expect(diary, isNull);
    });

    test('forgets an expired key left from another diary', () async {
      await createAndClose();
      final staleCache = MemoryMasterKeyCache();
      await staleCache.write(Uint8List(32)..fillRange(0, 32, 7));

      final diary = await LocalDiary.openFromCache(
        files: files,
        crypto: crypto,
        cache: staleCache,
      );

      expect(diary, isNull);
      expect(await staleCache.read(), isNull);
    });
  });

  group('openWithPassword', () {
    test('opens the diary on a new phone and fills its cache', () async {
      await createAndClose();
      final newPhone = MemoryMasterKeyCache();

      final diary = await LocalDiary.openWithPassword(
        files: files,
        password: password,
        crypto: crypto,
        cache: newPhone,
      );
      addTearDown(diary.close);

      expect(await storageMode(diary), 'local_only');
      expect(await newPhone.read(), isNotNull);
    });

    test('refuses a wrong password and caches nothing', () async {
      await createAndClose();
      final newPhone = MemoryMasterKeyCache();

      await expectLater(
        LocalDiary.openWithPassword(
          files: files,
          password: 'wrong password',
          crypto: crypto,
          cache: newPhone,
        ),
        throwsA(isA<WrongSecretException>()),
      );
      expect(await newPhone.read(), isNull);
    });
  });

  test('openWithRecoveryKey opens the diary without the password', () async {
    final (_, recoveryKey) = await createAndClose();

    final diary = await LocalDiary.openWithRecoveryKey(
      files: files,
      recoveryKey: RecoveryKey.parse(recoveryKey.words.join(' ')),
      crypto: crypto,
      cache: MemoryMasterKeyCache(),
    );
    addTearDown(diary.close);

    expect(await storageMode(diary), 'local_only');
  });

  test('every way of opening refuses a folder with no diary', () async {
    await expectLater(
      LocalDiary.openWithPassword(
        files: files,
        password: password,
        crypto: crypto,
        cache: MemoryMasterKeyCache(),
      ),
      throwsA(isA<DiaryNotFoundException>()),
    );
  });

  test('a reopened diary updates the same day', () async {
    final cache = MemoryMasterKeyCache();
    final created = await LocalDiary.create(
      files: files,
      password: password,
      crypto: crypto,
      cache: cache,
    );
    final day = LocalDate(2026, 10, 29);

    await created.diary.entries.save(
      day,
      moods: const WholeDayMood(MoodScore.low),
    );

    await created.diary.close();

    final diary = await LocalDiary.openWithPassword(
      files: files,
      password: password,
      crypto: crypto,
      cache: cache,
    );

    addTearDown(diary.close);

    await diary.entries.save(day, moods: const WholeDayMood(MoodScore.good));

    final entry = await diary.entries.watchDay(day).first;

    expect(entry!.moods, const WholeDayMood(MoodScore.good));
  });
}
