import 'dart:convert';
import 'dart:typed_data';

import 'package:lumaely_crypto/src/password_lock.dart';
import 'package:lumaely_crypto/src/recovery/recovery_lock.dart';
import 'package:meta/meta.dart';

/// The content of `diary.lmkey`: the master key locked twice,
/// once by the password and once by the recovery key.
///
/// Version 2 holds the same fields as the cloud's key bundle, so a diary
/// can later be sent to the cloud as it is:
///
/// ```json
/// {
///   "format": "lumaely-key",
///   "version": 2,
///   "kdf_salt": "base64, 16 bytes",
///   "kdf_params": {"alg": "argon2id", "m": 65536, "t": 3, "p": 1},
///   "wrapped_key_password": "base64, nonce + ciphertext + tag",
///   "wrapped_key_recovery": "base64, nonce + ciphertext + tag"
/// }
/// ```
@immutable
final class KeyFile {
  /// Creates a key file from its two locks.
  const new({required this.passwordLock, required this.recoveryLock});

  /// Reads the text of a `diary.lmkey` file.
  ///
  /// Throws [FormatException] if it is not a Lumaely key file, if its
  /// version is not 2 (version 1 came before the cloud key scheme, and
  /// nothing was distributed with it), or if a field is missing or wrong.
  factory decode(String text) {
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      throw const FormatException('Not a Lumaely key file');
    }

    if (json case {'format': 'lumaely-key', 'version': final int version}) {
      if (version > currentVersion) {
        throw const FormatException('Written by a newer version of Lumaely');
      }
      if (version < currentVersion) {
        throw FormatException('Key file version $version is not supported');
      }
    } else {
      throw const FormatException('Not a Lumaely key file');
    }

    if (json case {
      'kdf_salt': final String salt,
      'kdf_params': {
        'alg': 'argon2id',
        'm': final int memoryKib,
        't': final int passes,
        'p': 1,
      },
      'wrapped_key_password': final String wrappedByPassword,
      'wrapped_key_recovery': final String wrappedByRecovery,
    }) {
      return KeyFile(
        passwordLock: PasswordLock(
          salt: _bytes(salt, saltLength),
          opsLimit: passes,
          memLimit: memoryKib * 1024,
          wrappedKey: _bytes(wrappedByPassword, wrappedKeyLength),
        ),
        recoveryLock: RecoveryLock(
          wrappedKey: _bytes(wrappedByRecovery, wrappedKeyLength),
        ),
      );
    }

    throw const FormatException('A field is missing from the key file');
  }

  /// Version written by this code.
  static const currentVersion = 2;

  /// Argon2id salt, in bytes (libsodium's size, the cloud's too).
  static const saltLength = 16;

  /// A wrapped master key: 24-byte nonce, 32-byte key, 16-byte tag.
  static const int wrappedKeyLength = 24 + 32 + 16;

  /// The master key locked by the password.
  final PasswordLock passwordLock;

  /// The master key locked by the recovery key.
  final RecoveryLock recoveryLock;

  /// Same file with a new password lock; the recovery lock is kept.
  KeyFile withPasswordLock(PasswordLock lock) =>
      KeyFile(passwordLock: lock, recoveryLock: recoveryLock);

  /// The text to write to `diary.lmkey`.
  String encode() {
    return const JsonEncoder.withIndent('  ').convert({
      'format': 'lumaely-key',
      'version': currentVersion,
      'kdf_salt': base64Encode(passwordLock.salt),
      // the cloud's names: m in KiB, t passes, p lanes (always 1 in
      // libsodium)
      'kdf_params': {
        'alg': 'argon2id',
        'm': passwordLock.memLimit ~/ 1024,
        't': passwordLock.opsLimit,
        'p': 1,
      },
      'wrapped_key_password': base64Encode(passwordLock.wrappedKey),
      'wrapped_key_recovery': base64Encode(recoveryLock.wrappedKey),
    });
  }

  // base64 of exactly [length] bytes
  static Uint8List _bytes(String base64, int length) {
    final bytes = base64Decode(base64);
    if (bytes.length != length) {
      throw FormatException('Expected $length bytes, got ${bytes.length}');
    }
    return bytes;
  }
}
