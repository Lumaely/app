import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/data/vault/secure_storage_master_key_cache.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:path/path.dart' as p;

/// a real open diary in a temp folder, for tests that need VaultOpen
/// LocalDiary is a final class so it can't be faked, so we need to create a
/// real one.
/// Call it from setUpAll (not inside testWidgets: it runs isolates); it
///   is closed and deleted after the tests
Future<LocalDiary> createTestDiary() async {
  FlutterSecureStorage.setMockInitialValues({});

  final folder = await Directory.systemTemp.createTemp('lumaely_test__diary_');
  final created = await LocalDiary.create(
    files: DiaryFiles(Directory(p.join(folder.path, 'diary'))),
    password: 'hilol',
    crypto: await LmCryptoEngine.init(),
    cache: SecureStorageMasterKeyCache(),
  );

  addTearDown(() async {
    await created.diary.close();
    await folder.delete(recursive: true);
  });

  return created.diary;
}
