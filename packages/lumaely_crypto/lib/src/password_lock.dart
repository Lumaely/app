import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A master key locked by a password: everything needed to unlock it again,
/// except the password itself.
@immutable
final class PasswordLock {
  /// Creates a lock from its stored parts.
  const new({
    required this.salt,
    required this.opsLimit,
    required this.memLimit,
    required this.wrappedKey,
  });

  /// Random bytes mixed with the password by Argon2id.
  final Uint8List salt;

  /// Argon2id passes over memory.
  final int opsLimit;

  /// Argon2id memory, in bytes.
  final int memLimit;

  /// The sealed master key: the 24-byte nonce, then the ciphertext and its
  /// tag (XChaCha20-Poly1305), as the cloud stores it.
  final Uint8List wrappedKey;
}

/// Thrown when a password (or recovery key) does not open a lock.
final class WrongSecretException implements Exception {
  const new();

  @override
  String toString() =>
      'WrongSecretException: this secret does not open the lock';
}
