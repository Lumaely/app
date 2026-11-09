import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/data/vault/vault.dart';
import 'package:lumaely/data/vault/vault_providers.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:path/path.dart' as p;

void main() {
  const password = 'hilol';

  late LmCryptoEngine crypto;
  late DiaryFiles files;

  setUpAll(() async => crypto = await LmCryptoEngine.init());

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    final folder = await Directory.systemTemp.createTemp(
      'lumaely_test__vault_',
    );
    addTearDown(() => folder.delete(recursive: true));
    files = DiaryFiles(Directory(p.join(folder.path, 'diary')));
  });

  Future<void> closeDiary(ProviderContainer container) async {
    if (container.read(vaultProvider).value case VaultOpen(:final diary)) {
      await diary.close();
    }
  }

  ProviderContainer makeContainer() {
    final container = ProviderContainer.test(
      overrides: [
        cryptoEngineProvider.overrideWithValue(crypto),
        diaryFilesProvider.overrideWithValue(files),
      ],
    );
    addTearDown(() => closeDiary(container));
    return container;
  }

  /// Closes the diary and rebuilds the vault (simulates like an app restart)
  Future<VaultState> restart(ProviderContainer container) async {
    await closeDiary(container);
    container.invalidate(vaultProvider);
    return await container.read(vaultProvider.future);
  }

  Future<RecoveryKey> createDiary(ProviderContainer container) async {
    await container.read(vaultProvider.future);
    return await container.read(vaultProvider.notifier).create(password);
  }

  /// Forgets the cached key (simulates like a new phone or a reinstall)
  Future<void> forgetCachedKey(ProviderContainer container) async {
    await container.read(masterKeyCacheProvider).clear();
    await restart(container);
  }

  test('is empty when there is no diary', () async {
    final container = makeContainer();

    expect(await container.read(vaultProvider.future), isA<VaultEmpty>());
  });

  test('create opens the diary and returns its recovery key', () async {
    final container = makeContainer();

    final recoveryKey = await createDiary(container);

    expect(recoveryKey.words, hasLength(RecoveryKey.wordCount));
    expect(container.read(vaultProvider).value, isA<VaultOpen>());
    expect(files.exists(), isTrue);
  });

  test('reopens from the cached key after a restart', () async {
    final container = makeContainer();

    await createDiary(container);
    expect(await restart(container), isA<VaultOpen>());
  });

  test('is locked when this device has no cached key', () async {
    final container = makeContainer();

    await createDiary(container);
    await forgetCachedKey(container);
    expect(container.read(vaultProvider).value, isA<VaultLocked>());
  });

  test('a wrong password keeps the vault locked', () async {
    final container = makeContainer();

    await createDiary(container);
    await forgetCachedKey(container);

    await expectLater(
      container.read(vaultProvider.notifier).unlockWithPassword('wrong'),
      throwsA(isA<WrongSecretException>()),
    );
    expect(container.read(vaultProvider).value, isA<VaultLocked>());
  });

  test('the password unlocks the vault', () async {
    final container = makeContainer();

    await createDiary(container);
    await forgetCachedKey(container);

    await container.read(vaultProvider.notifier).unlockWithPassword(password);

    expect(container.read(vaultProvider).value, isA<VaultOpen>());
  });

  test('the recovery key unlocks the vault', () async {
    final container = makeContainer();
    final recoveryKey = await createDiary(container);

    await forgetCachedKey(container);

    await container
        .read(vaultProvider.notifier)
        .unlockWithRecoveryKey(recoveryKey);

    expect(container.read(vaultProvider).value, isA<VaultOpen>());
  });
}
