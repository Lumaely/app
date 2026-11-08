import 'dart:typed_data';

import 'package:lumaely_crypto/src/key_purpose.dart';
import 'package:sodium/sodium.dart';

/// Lumaely's cryptography engine
/// Based on libsodium
class LmCryptoEngine {
  new _(this._sodium);

  /// Initializes libsodium.
  /// Call once when the app starts.
  static Future<LmCryptoEngine> init() async =>
      LmCryptoEngine._(await SodiumInit.init());

  final Sodium _sodium;

  /// Size in bytes of the master key and of every derived key.
  static const keyLength = 32;

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
}
