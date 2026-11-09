import 'dart:io';

import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:test/test.dart';

import '../support/memory_master_key_cache.dart';

void main() {
  const oldPassword = 'old password';
  const newPassword = 'new password';

  late LmCryptoEngine crypto;
  late Directory root;
  late DiaryFiles files;

  setUpAll(() async {
    crypto = await LmCryptoEngine.init();
  });

  setUp(() async {
    root = await Directory.systemTemp.createTemp(
      'lumaely_test__password_change_',
    );
    files = DiaryFiles(Directory('${root.path}/diary'));
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  Future<CreatedDiary> createDiary() async {
    final created = await LocalDiary.create(
      files: files,
      password: oldPassword,
      crypto: crypto,
      cache: MemoryMasterKeyCache(),
    );

    addTearDown(created.diary.close);
    return created;
  }

  Future<LocalDiary> openWith(String password) async {
    final diary = await LocalDiary.openWithPassword(
      files: files,
      password: password,
      crypto: crypto,
      cache: MemoryMasterKeyCache(),
    );

    addTearDown(diary.close);
    return diary;
  }

  test('after a change, only the new password opens the diary', () async {
    final createdDiary = await createDiary();

    await createdDiary.diary.changePassword(
      currentPassword: oldPassword,
      newPassword: newPassword,
    );
    await createdDiary.diary.close();

    await openWith(newPassword);

    await expectLater(
      openWith(oldPassword),
      throwsA(isA<WrongSecretException>()),
    );
  });

  test('the recovery key still works after a change', () async {
    final createdDiary = await createDiary();
    await createdDiary.diary.changePassword(
      currentPassword: oldPassword,
      newPassword: newPassword,
    );
    await createdDiary.diary.close();

    final diary = await LocalDiary.openWithRecoveryKey(
      files: files,
      recoveryKey: createdDiary.recoveryKey,
      crypto: crypto,
      cache: MemoryMasterKeyCache(),
    );

    addTearDown(diary.close);
  });

  test('a wrong current password changes nothing', () async {
    final created = await createDiary();
    final before = await files.keyFile.readAsString();

    await expectLater(
      created.diary.changePassword(
        currentPassword: 'wrong password lol',
        newPassword: newPassword,
      ),
      throwsA(isA<WrongSecretException>()),
    );

    expect(await files.keyFile.readAsString(), before);
  });

  test('a forgotten password can be replaced after recovery', () async {
    final created = await createDiary();
    await created.diary.close();

    final recoveredDiary = await LocalDiary.openWithRecoveryKey(
      files: files,
      recoveryKey: created.recoveryKey,
      crypto: crypto,
      cache: MemoryMasterKeyCache(),
    );

    addTearDown(recoveredDiary.close);
    await recoveredDiary.setPasswordAfterRecovery(newPassword);
    await recoveredDiary.close();

    await openWith(newPassword);
  });

  test('a closed diary refuses to change its password', () async {
    final created = await createDiary();
    await created.diary.close();

    await expectLater(
      created.diary.changePassword(
        currentPassword: oldPassword,
        newPassword: newPassword,
      ),
      throwsStateError,
    );
  });
}
