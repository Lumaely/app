import 'dart:convert';
import 'dart:typed_data';

import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:sodium/sodium_sumo.dart';

/// Lumaely's cryptography engine
/// Based on libsodium
class LmCryptoEngine {
  new _(this._sodium);

  /// Initializes libsodium.
  /// Call once when the app starts.
  static Future<LmCryptoEngine> init() async =>
      LmCryptoEngine._(await SodiumSumoInit.init());

  final SodiumSumo _sodium;

  /// Size in bytes of the master key and of every derived key.
  static const keyLength = 32;

  /// Argon2id settings
  /// 3 passes
  static const _opsLimit = 3;

  /// over 64 MB of memory
  static const int _memLimit = 64 * 1024 * 1024;

  static final Uint8List _passwordLockLabel = utf8.encode(
    'lumaely.master_key.password.v1',
  );

  static final Uint8List _recoveryLockLabel = utf8.encode(
    'lumaely.master_key.recovery.v1',
  );

  Aead get _aead => _sodium.crypto.aeadXChaCha20Poly1305IETF;

  // === key ===

  /// Creates a new random master key, once, when a diary is created.
  SecureKey generateMasterKey() => _sodium.crypto.kdf.keygen();

  /// Rebuilds the master key from stored bytes (e.g. from the Keychain).
  SecureKey masterKeyFromBytes(Uint8List bytes) {
    if (bytes.length != keyLength) {
      throw ArgumentError.value(
        bytes.length,
        'bytes.length',
        'A master key is $keyLength bytes',
      );
    }
    return _sodium.secureCopy(bytes);
  }

  /// Derives the key for [purpose] from [masterKey].
  SecureKey deriveKey(SecureKey masterKey, KeyPurpose purpose) {
    return _sodium.crypto.kdf.deriveFromKey(
      masterKey: masterKey,
      context: purpose.context,
      subkeyId: BigInt.one,
      subkeyLen: keyLength,
    );
  }

  // === password ===

  /// Locks [masterKey] with [password].
  PasswordLock lockWithPassword(SecureKey masterKey, String password) {
    final salt = _sodium.randombytes.buf(_sodium.crypto.pwhash.saltBytes);
    final lockKey = _keyFromPassword(password, salt, _opsLimit, _memLimit);

    try {
      final nonce = _sodium.randombytes.buf(_aead.nonceBytes);
      final cipherText = masterKey.runUnlockedSync(
        (bytes) => _aead.encrypt(
          message: bytes,
          nonce: nonce,
          key: lockKey,
          additionalData: _passwordLockLabel,
        ),
      );

      return PasswordLock(
        salt: salt,
        opsLimit: _opsLimit,
        memLimit: _memLimit,
        nonce: nonce,
        cipherText: cipherText,
      );
    } finally {
      lockKey.dispose();
    }
  }

  /// Opens [lock] with [password] and returns the master key.
  ///
  /// Throws [WrongSecretException] if the password is wrong.
  SecureKey unlockWithPassword(PasswordLock lock, String password) {
    final lockKey = _keyFromPassword(
      password,
      lock.salt,
      lock.opsLimit,
      lock.memLimit,
    );

    try {
      final bytes = _aead.decrypt(
        cipherText: lock.cipherText,
        nonce: lock.nonce,
        key: lockKey,
        additionalData: _passwordLockLabel,
      );

      try {
        return _sodium.secureCopy(bytes);
      } finally {
        bytes.fillRange(0, bytes.length, 0);
      }
    } on SodiumException {
      throw const WrongSecretException();
    } finally {
      lockKey.dispose();
    }
  }

  SecureKey _keyFromPassword(
    String password,
    Uint8List salt,
    int opsLimit,
    int memLimit,
  ) {
    return _sodium.crypto.pwhash.callStr(
      outLen: _aead.keyBytes,
      password: password,
      salt: salt,
      opsLimit: opsLimit,
      memLimit: memLimit,
      alg: CryptoPwhashAlgorithm.argon2id13,
    );
  }

  // === recovery key ===

  /// Creates a new random recovery key, shown once to the person.
  RecoveryKey generateRecoveryKey() {
    final entropy = _sodium.randombytes.buf(RecoveryKey.entropyLength);

    try {
      return RecoveryKey.fromEntropy(entropy);
    } finally {
      entropy.fillRange(0, entropy.length, 0);
    }
  }

  /// Locks [masterKey] with [recoveryKey].
  RecoveryLock lockWithRecoveryKey(
    SecureKey masterKey,
    RecoveryKey recoveryKey,
  ) {
    final lockKey = _keyFromRecovery(recoveryKey);

    try {
      final nonce = _sodium.randombytes.buf(_aead.nonceBytes);
      final cipherText = masterKey.runUnlockedSync(
        (bytes) => _aead.encrypt(
          message: bytes,
          nonce: nonce,
          key: lockKey,
          additionalData: _recoveryLockLabel,
        ),
      );

      return RecoveryLock(nonce: nonce, cipherText: cipherText);
    } finally {
      lockKey.dispose();
    }
  }

  /// Opens [lock] with [recoveryKey] and returns the master key.
  ///
  /// Throws [WrongSecretException] if the recovery key is wrong.
  SecureKey unlockWithRecoveryKey(RecoveryLock lock, RecoveryKey recoveryKey) {
    final lockKey = _keyFromRecovery(recoveryKey);

    try {
      final bytes = _aead.decrypt(
        cipherText: lock.cipherText,
        nonce: lock.nonce,
        key: lockKey,
        additionalData: _recoveryLockLabel,
      );

      try {
        return _sodium.secureCopy(bytes);
      } finally {
        bytes.fillRange(0, bytes.length, 0);
      }
    } on SodiumException {
      throw const WrongSecretException();
    } finally {
      lockKey.dispose();
    }
  }

  SecureKey _keyFromRecovery(RecoveryKey recoveryKey) {
    final entropy = recoveryKey.extractEntropy();

    try {
      return _sodium.secureCopy(entropy);
    } finally {
      entropy.fillRange(0, entropy.length, 0);
    }
  }
}
