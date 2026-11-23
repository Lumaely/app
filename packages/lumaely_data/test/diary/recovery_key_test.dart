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
    root = await Directory.systemTemp.createTemp('lumaely_test__recovery_');
    files = DiaryFiles(Directory('${root.path}/diary'));
    cache = MemoryMasterKeyCache();
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  Future<CreatedDiary> createDiary() => LocalDiary.create(
    files: files,
    password: 'hilol',
    crypto: crypto,
    cache: cache,
  );

  Future<LocalDiary> reopen() async {
    final diary = await LocalDiary.openFromCache(
      files: files,
      crypto: crypto,
      cache: cache,
    );
    return diary!;
  }

  test('a new diary has an unconfirmed recovery key', () async {
    final created = await createDiary();
    addTearDown(created.diary.close);

    expect(await created.diary.isRecoveryKeyConfirmed(), isFalse);
  });

  test('the confirmation is kept when the diary opens again', () async {
    final created = await createDiary();
    await created.diary.confirmRecoveryKey();
    await created.diary.close();

    final diary = await reopen();
    addTearDown(diary.close);

    expect(await diary.isRecoveryKeyConfirmed(), isTrue);
  });

  test('confirming twice is fine', () async {
    final created = await createDiary();
    addTearDown(created.diary.close);

    await created.diary.confirmRecoveryKey();
    await created.diary.confirmRecoveryKey();

    expect(await created.diary.isRecoveryKeyConfirmed(), isTrue);
  });

  test('a new recovery key replaces the old one, the password stays', () async {
    final created = await createDiary();
    addTearDown(created.diary.close);

    final newKey = await created.diary.replaceRecoveryKey();
    final keyFile = await files.readKeyFile();

    expect(newKey, isNot(created.recoveryKey));
    expect(
      () => crypto.unlockWithRecoveryKey(
        keyFile.recoveryLock,
        created.recoveryKey,
      ),
      throwsA(isA<WrongSecretException>()),
    );
    final byNewKey = crypto.unlockWithRecoveryKey(keyFile.recoveryLock, newKey);
    addTearDown(byNewKey.dispose);
    final byPassword = await crypto.unlockWithPassword(
      keyFile.passwordLock,
      'hilol',
    );
    addTearDown(byPassword.dispose);
    expect(byNewKey.extractBytes(), byPassword.extractBytes());
  });
}
