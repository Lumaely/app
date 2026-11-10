import 'dart:typed_data';

import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:test/test.dart';

void main() {
  late LmCryptoEngine crypto;

  setUpAll(() async {
    crypto = await LmCryptoEngine.init();
  });

  test('size of master key is 32 bytes + master key should be random', () {
    final a = crypto.generateMasterKey();
    final b = crypto.generateMasterKey();
    addTearDown(a.dispose);
    addTearDown(b.dispose);

    expect(a.length, 32);
    expect(a.extractBytes(), isNot(equals(b.extractBytes())));
  });

  test('the same master key always gives the same database key', () {
    final master = crypto.generateMasterKey();
    final copy = crypto.masterKeyFromBytes(master.extractBytes());
    final first = crypto.deriveKey(master, KeyPurpose.database);
    final second = crypto.deriveKey(copy, KeyPurpose.database);
    for (final key in [master, copy, first, second]) {
      addTearDown(key.dispose);
    }

    expect(first.extractBytes(), equals(second.extractBytes()));
  });

  test('database key is not the master key', () {
    final master = crypto.generateMasterKey();
    final dbKey = crypto.deriveKey(master, KeyPurpose.database);
    addTearDown(master.dispose);
    addTearDown(dbKey.dispose);

    expect(dbKey.extractBytes(), isNot(equals(master.extractBytes())));
  });

  test('two master keys give two different database keys', () {
    final a = crypto.generateMasterKey();
    final b = crypto.generateMasterKey();
    final keyA = crypto.deriveKey(a, KeyPurpose.database);
    final keyB = crypto.deriveKey(b, KeyPurpose.database);
    for (final key in [a, b, keyA, keyB]) {
      addTearDown(key.dispose);
    }

    expect(keyA.extractBytes(), isNot(equals(keyB.extractBytes())));
  });

  test('refuses a master key of the wrong size', () {
    expect(() => crypto.masterKeyFromBytes(Uint8List(16)), throwsArgumentError);
  });

  test('key contexts never change', () {
    expect(
      {for (final purpose in KeyPurpose.values) purpose: purpose.context},
      {
        KeyPurpose.database: 'lmy_db__',
        KeyPurpose.sync: 'lmy_sync',
        KeyPurpose.recordIds: 'lmy_ids_',
      },
    );
  });
}
