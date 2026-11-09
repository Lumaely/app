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

  test('refuses files that are not .lmkey files', () {
    expect(() => KeyFile.decode('hello'), throwsFormatException);
    expect(() => KeyFile.decode('{"format": "other"}'), throwsFormatException);

    final validFile = jsonEncode({
      'format': 'lumaely-key',
      'version': KeyFile.currentVersion,
      'slots': <Object>[],
    });

    expect(() => KeyFile.decode(validFile), throwsFormatException);
  });

  test('refuses files from a newer version', () {
    final file = jsonEncode({
      'format': 'lumaely-key',
      'version': KeyFile.currentVersion + 1,
      'slots': <Object>[],
    });

    expect(() => KeyFile.decode(file), throwsFormatException);
  });
}
