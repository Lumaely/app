import 'dart:io';

import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:test/test.dart';

import '../support/memory_master_key_cache.dart';

void main() {
  late LmCryptoEngine crypto;
  late Directory root;
  late DiaryFiles files;
  late MemoryMasterKeyCache cache;

  setUpAll(() async {
    crypto = await LmCryptoEngine.init();
  });

  setUp(() async {
    root = await Directory.systemTemp.createTemp('lumaely_test__diary_create_');
    files = DiaryFiles(Directory('${root.path}/diary'));
    cache = MemoryMasterKeyCache();
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  Future<CreatedDiary> createDiary() async {
    final created = await LocalDiary.create(
      files: files,
      password: 'hilol',
      crypto: crypto,
      cache: cache,
    );
    addTearDown(created.diary.close);
    return created;
  }

  test('writes the key file and the database', () async {
    await createDiary();

    expect(files.keyFile.existsSync(), isTrue);
    expect(files.database.existsSync(), isTrue);
  });

  test('gives a 24-word recovery key that opens the key file', () async {
    final created = await createDiary();

    expect(created.recoveryKey.words, hasLength(24));

    final keyFile = await files.readKeyFile();
    final master = crypto.unlockWithRecoveryKey(
      keyFile.recoveryLock,
      created.recoveryKey,
    );

    addTearDown(master.dispose);
  });

  test('caches the same master key the password unlocks', () async {
    await createDiary();

    final keyFile = await files.readKeyFile();
    final master = await crypto.unlockWithPassword(
      keyFile.passwordLock,
      'hilol',
    );
    addTearDown(master.dispose);

    expect(await cache.read(), equals(master.extractBytes()));
  });

  test('records the storage mode in the database', () async {
    final created = await createDiary();
    final db = created.diary.database;

    final mode = await (db.select(
      db.databaseMeta,
    )..where((row) => row.name.equals('storage_mode'))).getSingle();

    expect(mode.value, 'local_only');
  });

  test('refuses to create over an existing diary', () async {
    await createDiary();
    final before = await files.keyFile.readAsString();

    await expectLater(
      LocalDiary.create(
        files: files,
        password: 'evil hi lol',
        crypto: crypto,
        cache: cache,
      ),
      throwsA(isA<DiaryAlreadyExistsException>()),
    );
    expect(await files.keyFile.readAsString(), before);
  });
}
