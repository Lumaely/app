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

  /// Argon2id output, as the cloud expects: the auth key (first 32 bytes)
  /// then the key that seals the master key (last 32 bytes)
  static const int _passwordKeysLength = 2 * keyLength;

  static final Uint8List _passwordLockLabel = utf8.encode(
    'lumaely.master_key.password.v1',
  );

  static final Uint8List _recoveryLockLabel = utf8.encode(
    'lumaely.master_key.recovery.v1',
  );

  /// HKDF-SHA256 labels (info) of the two keys made from the recovery key.
  /// Stored formats: NEVER change them, a golden test freezes them.
  /// - auth key: checked by the server once sync comes
  static const recoveryAuthKeyLabel = 'lumaely:recovery:auth_key';

  /// - the key that seals the master key
  static const recoverySealingKeyLabel = 'lumaely:recovery:sealing_key';

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

  /// Locks [masterKey] with [password], in an isolate.
  Future<PasswordLock> lockWithPassword(SecureKey masterKey, String password) =>
      _sodium.runIsolated(
        (secureKeys, _) => _lockWithPassword(secureKeys.single, password),
        secureKeys: [masterKey],
      );

  /// Opens [lock] with [password] and returns the master key, in an isolate.
  ///
  /// Throws [WrongSecretException] if the password is wrong.
  Future<SecureKey> unlockWithPassword(PasswordLock lock, String password) =>
      _sodium.runIsolated((_, _) => _unlockWithPassword(lock, password));

  /// Locks [masterKey] with [password].
  PasswordLock _lockWithPassword(SecureKey masterKey, String password) {
    final salt = _sodium.randombytes.buf(_sodium.crypto.pwhash.saltBytes);
    final lockKey = _sealingKeyFromPassword(
      password,
      salt,
      _opsLimit,
      _memLimit,
    );

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

      // we're recreating lists (Uint8List.fromList()) because otherwise
      // a segfault happens (use-after-free, after isolate ends).
      return PasswordLock(
        salt: Uint8List.fromList(salt),
        opsLimit: _opsLimit,
        memLimit: _memLimit,
        nonce: Uint8List.fromList(nonce),
        cipherText: Uint8List.fromList(cipherText),
      );
    } finally {
      lockKey.dispose();
    }
  }

  /// Opens [lock] with [password] and returns the master key.
  ///
  /// Throws [WrongSecretException] if the password is wrong.
  SecureKey _unlockWithPassword(PasswordLock lock, String password) {
    final lockKey = _sealingKeyFromPassword(
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

  /// The key that seals the master key: the last 32 bytes of Argon2id.
  ///
  /// - the first 32 are the auth key, checked by the server once sync comes;
  ///   unused locally, so wiped right away
  /// - both halves come from one 64-byte output: a 32-byte output would not
  ///   give the same bytes
  SecureKey _sealingKeyFromPassword(
    String password,
    Uint8List salt,
    int opsLimit,
    int memLimit,
  ) {
    final keys = _sodium.crypto.pwhash.callStr(
      outLen: _passwordKeysLength,
      password: password,
      salt: salt,
      opsLimit: opsLimit,
      memLimit: memLimit,
      alg: CryptoPwhashAlgorithm.argon2id13,
    );

    try {
      // a view, not a copy: the bytes never leave libsodium's memory
      return keys.runUnlockedSync(
        (bytes) => _sodium.secureCopy(Uint8List.sublistView(bytes, keyLength)),
      );
    } finally {
      keys.dispose();
    }
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
    final lockKey = _sealingKeyFromRecovery(recoveryKey);

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
    final lockKey = _sealingKeyFromRecovery(recoveryKey);

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

  /// The key that seals the master key, from the recovery key's 32 bytes,
  /// through HKDF-SHA256 (as the cloud expects).
  ///
  /// - extract (no salt), then expand with [recoverySealingKeyLabel]
  /// - the same extract with [recoveryAuthKeyLabel] gives the auth key; it
  ///   comes with sync, nothing uses it locally
  SecureKey _sealingKeyFromRecovery(RecoveryKey recoveryKey) {
    final hkdf = _sodium.crypto.kdfHkdfSha256;
    final entropy = recoveryKey.extractEntropy();

    final SecureKey pseudoRandomKey;
    try {
      pseudoRandomKey = hkdf.extract(ikm: entropy);
    } finally {
      entropy.fillRange(0, entropy.length, 0);
    }

    try {
      return hkdf.expand(
        masterKey: pseudoRandomKey,
        context: recoverySealingKeyLabel,
        outLen: keyLength,
      );
    } finally {
      pseudoRandomKey.dispose();
    }
  }

  // === record ids ===

  /// Computes the id of a record from its [label] (for example
  /// `entry:2026-10-29`) using HMAC ([_sodium.crypto.auth()]).
  /// HMAC is basically hash + private key.
  ///
  /// The same [idKey] and [label] always give the same id, on every device.
  /// Without [idKey], nobody can tell which label an id comes from.
  String recordId(SecureKey idKey, String label) {
    final tag = _sodium.crypto.auth(message: utf8.encode(label), key: idKey);

    return tag.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
