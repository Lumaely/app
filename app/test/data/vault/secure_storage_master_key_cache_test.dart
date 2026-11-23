import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/data/vault/secure_storage_master_key_cache.dart';
import 'package:lumaely_data/lumaely_data.dart';

void main() {
  late SecureStorageMasterKeyCache cache;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    cache = SecureStorageMasterKeyCache();
  });

  final key = Uint8List.fromList(List.generate(32, (i) => i));

  test('is empty on a new device', () async {
    expect(await cache.read(), isNull);
  });

  test('gives back the key it stored', () async {
    await cache.write(key);

    expect(await cache.read(), equals(key));
  });

  test('forgets the key when cleared', () async {
    await cache.write(key);
    await cache.clear();

    expect(await cache.read(), isNull);
  });

  test('forgets an entry it cannot decode', () async {
    FlutterSecureStorage.setMockInitialValues({
      SecureStorageMasterKeyCache.entryName: 'not base64 lol',
    });
    cache = SecureStorageMasterKeyCache();

    expect(await cache.read(), isNull);
    expect(await cache.read(), isNull);
  });

  test('a refused write says so', () async {
    final refusing = SecureStorageMasterKeyCache(storage: _RefusingStorage());

    await expectLater(
      refusing.write(key),
      throwsA(isA<MasterKeyCacheException>()),
    );
  });
}

/// a secure storage that refuses every write, like a locked keychain
class _RefusingStorage extends Fake implements FlutterSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw PlatformException(code: 'locked');
  }
}
