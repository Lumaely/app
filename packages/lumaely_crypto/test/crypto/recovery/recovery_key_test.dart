import 'dart:typed_data';

import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:test/test.dart';

void main() {
  group('RecoveryKey words', () {
    test('matches the official BIP-39 test vectors', () {
      final zeros = RecoveryKey.fromEntropy(Uint8List(32));
      expect(zeros.words.join(' '), '${'abandon ' * 23}art');

      final ones = RecoveryKey.fromEntropy(
        Uint8List(32)..fillRange(0, 32, 0xFF),
      );
      expect(ones.words.join(' '), '${'zoo ' * 23}vote');
    });

    test('reads back the words it wrote', () {
      final key = RecoveryKey.fromEntropy(
        Uint8List.fromList(List.generate(32, (i) => i * 7)),
      );
      expect(RecoveryKey.parse(key.words.join(' ')), key);
    });

    test('ignores capitals, extra spaces and line breaks', () {
      final key = RecoveryKey.parse('  ${'ABANDON\n' * 23}Art ');
      expect(key, RecoveryKey.fromEntropy(Uint8List(32)));
    });

    test('catches a typo with the checksum', () {
      expect(
        () => RecoveryKey.parse(('abandon ' * 24).trim()),
        throwsFormatException,
      );
    });

    test('refuses unknown words and wrong counts', () {
      expect(
        () => RecoveryKey.parse('${'abandon ' * 23}arrt'),
        throwsFormatException,
      );
      expect(() => RecoveryKey.parse('abandon art'), throwsFormatException);
    });

    test('never prints its words', () {
      expect(
        RecoveryKey.fromEntropy(Uint8List(32)).toString(),
        'RecoveryKey(hidden)',
      );
    });
  });

  group('RecoveryLock', () {
    late LmCryptoEngine crypto;

    setUpAll(() async {
      crypto = await LmCryptoEngine.init();
    });

    test('the right recovery key gives back the master key', () {
      final master = crypto.generateMasterKey();
      addTearDown(master.dispose);
      final recovery = crypto.generateRecoveryKey();

      final lock = crypto.lockWithRecoveryKey(master, recovery);
      final typedBack = RecoveryKey.parse(recovery.words.join(' '));
      final unlocked = crypto.unlockWithRecoveryKey(lock, typedBack);
      addTearDown(unlocked.dispose);

      expect(unlocked.extractBytes(), equals(master.extractBytes()));
    });

    test('another recovery key is refused', () {
      final master = crypto.generateMasterKey();
      addTearDown(master.dispose);
      final lock = crypto.lockWithRecoveryKey(
        master,
        crypto.generateRecoveryKey(),
      );

      expect(
        () => crypto.unlockWithRecoveryKey(lock, crypto.generateRecoveryKey()),
        throwsA(isA<WrongSecretException>()),
      );
    });
  });
}
