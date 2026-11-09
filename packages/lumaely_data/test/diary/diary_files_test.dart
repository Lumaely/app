import 'dart:io';

import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:test/test.dart';

void main() {
  late LmCryptoEngine crypto;
  late Directory root;
  late DiaryFiles files;

  setUpAll(() async {
    crypto = await LmCryptoEngine.init();
  });

  setUp(() async {
    root = await Directory.systemTemp.createTemp('lumaely_test__diary_files_');
    files = DiaryFiles(Directory('${root.path}/diary'));
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  Future<KeyFile> newKeyFile(String password) async {
    final master = crypto.generateMasterKey();

    addTearDown(master.dispose);

    return KeyFile(
      passwordLock: await crypto.lockWithPassword(master, password),
      recoveryLock: crypto.lockWithRecoveryKey(
        master,
        crypto.generateRecoveryKey(),
      ),
    );
  }

  test('no diary until a key file is written', () async {
    expect(files.exists(), isFalse);

    await files.writeKeyFile(await newKeyFile('hilol'));

    expect(files.exists(), isTrue);
  });

  test('reads back the key file it wrote', () async {
    final written = await newKeyFile('hilol');
    await files.writeKeyFile(written);

    final read = await files.readKeyFile();

    expect(read.encode(), written.encode());
  });

  test('leaves no temporary file behind', () async {
    await files.writeKeyFile(await newKeyFile('hilol'));

    expect(File('${files.keyFile.path}.tmp').existsSync(), isFalse);
  });

  test('a second write replaces the first', () async {
    await files.writeKeyFile(await newKeyFile('first'));
    final second = await newKeyFile('second');
    await files.writeKeyFile(second);

    expect((await files.readKeyFile()).encode(), second.encode());
  });
}
