import 'dart:convert';
import 'dart:typed_data';

import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:sodium/sodium_sumo.dart';
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

    await expectLater(
      crypto.unlockWithPassword(tampered, 'hilol'),
      throwsA(isA<WrongSecretException>()),
    );
  });

  // the cloud key scheme: Argon2id gives 64 bytes, the first 32 are the auth
  // key, the last 32 seal the master key. Rebuilt here with libsodium alone,
  // as the server or another app would.
  test('the last 32 bytes of a 64-byte Argon2id output seal the key', () async {
    final sodium = await SodiumSumoInit.init();
    final master = crypto.generateMasterKey();
    addTearDown(master.dispose);
    final lock = await crypto.lockWithPassword(master, 'hilol');

    final keys = sodium.crypto.pwhash.callStr(
      outLen: 64,
      password: 'hilol',
      salt: lock.salt,
      opsLimit: lock.opsLimit,
      memLimit: lock.memLimit,
      alg: CryptoPwhashAlgorithm.argon2id13,
    );
    addTearDown(keys.dispose);
    final sealingKey = sodium.secureCopy(keys.extractBytes().sublist(32));
    addTearDown(sealingKey.dispose);

    final unsealed = sodium.crypto.aeadXChaCha20Poly1305IETF.decrypt(
      cipherText: lock.cipherText,
      nonce: lock.nonce,
      key: sealingKey,
      additionalData: utf8.encode('lumaely.master_key.password.v1'),
    );

    expect(unsealed, master.extractBytes());
  });
}
