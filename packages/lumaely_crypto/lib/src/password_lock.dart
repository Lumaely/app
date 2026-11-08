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
    required this.nonce,
    required this.cipherText,
  });

  /// Random bytes mixed with the password by Argon2id.
  final Uint8List salt;

  /// Argon2id passes over memory.
  final int opsLimit;

  /// Argon2id memory, in bytes.
  final int memLimit;

  /// Random bytes used once by XChaCha20-Poly1305.
  final Uint8List nonce;

  /// The encrypted master key.
  final Uint8List cipherText;
}

/// Thrown when a password (or recovery key) does not open a lock.
final class WrongSecretException implements Exception {
  const new();

  @override
  String toString() =>
      'WrongSecretException: this secret does not open the lock';
}
