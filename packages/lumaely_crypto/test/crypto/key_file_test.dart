import 'dart:convert';

import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:test/test.dart';

void main() {
  late LmCryptoEngine crypto;

  setUpAll(() async {
    crypto = await LmCryptoEngine.init();
  });

  test(
    'a written key file opens with the password and the recovery key',
    () async {
      final master = crypto.generateMasterKey();
      addTearDown(master.dispose);
      final recovery = crypto.generateRecoveryKey();

      final text = KeyFile(
        passwordLock: await crypto.lockWithPassword(master, 'hilol'),
        recoveryLock: crypto.lockWithRecoveryKey(master, recovery),
      ).encode();
      final file = KeyFile.decode(text);

      final byPassword = await crypto.unlockWithPassword(
        file.passwordLock,
        'hilol',
      );
      final byRecovery = crypto.unlockWithRecoveryKey(
        file.recoveryLock,
        recovery,
      );

      addTearDown(byPassword.dispose);
      addTearDown(byRecovery.dispose);

      expect(byPassword.extractBytes(), equals(master.extractBytes()));
      expect(byRecovery.extractBytes(), equals(master.extractBytes()));
    },
  );

  test('the file never contains the master key itself', () async {
    final master = crypto.generateMasterKey();
    addTearDown(master.dispose);
    final text = KeyFile(
      passwordLock: await crypto.lockWithPassword(master, 'pw'),
      recoveryLock: crypto.lockWithRecoveryKey(
        master,
        crypto.generateRecoveryKey(),
      ),
    ).encode();

    expect(text, isNot(contains(base64Encode(master.extractBytes()))));
  });

  test('a new password keeps the recovery lock', () async {
    final master = crypto.generateMasterKey();
    addTearDown(master.dispose);
    final recovery = crypto.generateRecoveryKey();
    final file = KeyFile(
      passwordLock: await crypto.lockWithPassword(master, 'old password'),
      recoveryLock: crypto.lockWithRecoveryKey(master, recovery),
    );

    final changed = file.withPasswordLock(
      await crypto.lockWithPassword(master, 'new password'),
    );

    expect(changed.recoveryLock, same(file.recoveryLock));
    await expectLater(
      crypto.unlockWithPassword(changed.passwordLock, 'old password'),
      throwsA(isA<WrongSecretException>()),
    );
    final unlocked = await crypto.unlockWithPassword(
      changed.passwordLock,
      'new password',
    );
    addTearDown(unlocked.dispose);
    expect(unlocked.extractBytes(), equals(master.extractBytes()));
  });

  // the cloud's key bundle (cloud/src/docs/API.md), plus format and version
  test('holds the fields of the cloud key bundle', () async {
    final master = crypto.generateMasterKey();
    addTearDown(master.dispose);
    final text = KeyFile(
      passwordLock: await crypto.lockWithPassword(master, 'hilol'),
      recoveryLock: crypto.lockWithRecoveryKey(
        master,
        crypto.generateRecoveryKey(),
      ),
    ).encode();

    final json = jsonDecode(text) as Map<String, Object?>;

    expect(json.keys, {
      'format',
      'version',
      'kdf_salt',
      'kdf_params',
      'wrapped_key_password',
      'wrapped_key_recovery',
    });
    expect(json['format'], 'lumaely-key');
    expect(json['version'], KeyFile.currentVersion);
    expect(json['kdf_params'], {'alg': 'argon2id', 'm': 65536, 't': 3, 'p': 1});
    expect(base64Decode(json['kdf_salt']! as String), hasLength(16));
    for (final field in ['wrapped_key_password', 'wrapped_key_recovery']) {
      // 24-byte nonce, 32-byte key, 16-byte tag
      expect(base64Decode(json[field]! as String), hasLength(72));
    }
  });

  Future<Map<String, Object?>> validJson() async {
    final master = crypto.generateMasterKey();
    addTearDown(master.dispose);
    final text = KeyFile(
      passwordLock: await crypto.lockWithPassword(master, 'hilol'),
      recoveryLock: crypto.lockWithRecoveryKey(
        master,
        crypto.generateRecoveryKey(),
      ),
    ).encode();
    return jsonDecode(text) as Map<String, Object?>;
  }

  test('refuses files that are not .lmkey files', () async {
    expect(() => KeyFile.decode('hello'), throwsFormatException);
    expect(() => KeyFile.decode('{"format": "other"}'), throwsFormatException);

    final missing = await validJson()
      ..remove('wrapped_key_recovery');
    expect(() => KeyFile.decode(jsonEncode(missing)), throwsFormatException);
  });

  test('refuses other key derivations and wrong sizes', () async {
    final scrypt = await validJson()
      ..['kdf_params'] = {'alg': 'scrypt', 'm': 65536, 't': 3, 'p': 1};
    expect(() => KeyFile.decode(jsonEncode(scrypt)), throwsFormatException);

    final shortKey = await validJson()
      ..['wrapped_key_password'] = base64Encode(List.filled(40, 0));
    expect(() => KeyFile.decode(jsonEncode(shortKey)), throwsFormatException);
  });

  test('refuses version 1, from before the cloud key scheme', () async {
    final old = await validJson()
      ..['version'] = 1;

    expect(() => KeyFile.decode(jsonEncode(old)), throwsFormatException);
  });

  test('refuses files from a newer version', () async {
    final newer = await validJson()
      ..['version'] = KeyFile.currentVersion + 1;

    expect(() => KeyFile.decode(jsonEncode(newer)), throwsFormatException);
  });
}
