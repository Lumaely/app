import 'dart:typed_data';

import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:test/test.dart';

void main() {
  late LmCryptoEngine crypto;

  setUpAll(() async {
    crypto = await LmCryptoEngine.init();
  });

  test('the right password gives back the same master key', () async {
    final master = crypto.generateMasterKey();
    addTearDown(master.dispose);

    final lock = await crypto.lockWithPassword(master, 'hilol');
    final unlocked = await crypto.unlockWithPassword(lock, 'hilol');
    addTearDown(unlocked.dispose);

    expect(unlocked.extractBytes(), equals(master.extractBytes()));
  });

  test('a wrong password is refused', () async {
    final master = crypto.generateMasterKey();
    addTearDown(master.dispose);
    final lock = await crypto.lockWithPassword(master, 'hilol');

    await expectLater(
      crypto.unlockWithPassword(lock, 'BYElol'),
      throwsA(isA<WrongSecretException>()),
    );
  });

  test('locking twice gives two different locks', () async {
    final master = crypto.generateMasterKey();
    addTearDown(master.dispose);

    final a = await crypto.lockWithPassword(master, 'evil hi lol');
    final b = await crypto.lockWithPassword(master, 'evil hi lol');

    expect(a.salt, isNot(equals(b.salt)));
    expect(a.cipherText, isNot(equals(b.cipherText)));
  });

  test('a lock changed by one byte is refused', () async {
    final master = crypto.generateMasterKey();
    addTearDown(master.dispose);
    final lock = await crypto.lockWithPassword(master, 'hilol');

    final tampered = PasswordLock(
      salt: lock.salt,
      opsLimit: lock.opsLimit,
      memLimit: lock.memLimit,
      nonce: lock.nonce,
      cipherText: Uint8List.fromList(lock.cipherText)..[0] ^= 1,
    );

    expect(
      () => crypto.unlockWithPassword(tampered, 'hilol'),
      throwsA(isA<WrongSecretException>()),
    );
  });
}
