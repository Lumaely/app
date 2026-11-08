import 'dart:convert';

import 'package:lumaely_crypto/src/password_lock.dart';
import 'package:lumaely_crypto/src/recovery/recovery_lock.dart';
import 'package:meta/meta.dart';

/// The content of `diary.lmkey`: the master key locked twice,
/// once by the password and once by the recovery key.
@immutable
final class KeyFile {
  /// Creates a key file from its two locks.
  const new({required this.passwordLock, required this.recoveryLock});

  /// Reads the text of a `diary.lmkey` file.
  ///
  /// Throws [FormatException] if it is not a Lumaely key file, if it was
  /// written by a newer version of the app, or if a lock is missing.
  factory decode(String text) {
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      throw const FormatException('Not a Lumaely key file');
    }

    if (json case {
      'format': 'lumaely-key',
      'version': final int version,
      'slots': final List<Object?> slots,
    }) {
      if (version > currentVersion) {
        throw const FormatException('Written by a newer version of Lumaely');
      }

      PasswordLock? passwordLock;
      RecoveryLock? recoveryLock;
      for (final slot in slots) {
        switch (slot) {
          case {
            'type': 'password',
            'kdf': 'argon2id13',
            'salt': final String salt,
            'opsLimit': final int opsLimit,
            'memLimit': final int memLimit,
            'cipher': 'xchacha20poly1305-ietf',
            'nonce': final String nonce,
            'cipherText': final String cipherText,
          }:
            passwordLock = PasswordLock(
              salt: base64Decode(salt),
              opsLimit: opsLimit,
              memLimit: memLimit,
              nonce: base64Decode(nonce),
              cipherText: base64Decode(cipherText),
            );
          case {
            'type': 'recovery',
            'cipher': 'xchacha20poly1305-ietf',
            'nonce': final String nonce,
            'cipherText': final String cipherText,
          }:
            recoveryLock = RecoveryLock(
              nonce: base64Decode(nonce),
              cipherText: base64Decode(cipherText),
            );
          default: // Unknown slot type --> ignore
        }
      }

      if (passwordLock == null || recoveryLock == null) {
        throw const FormatException('A lock is missing from the key file');
      }
      return KeyFile(passwordLock: passwordLock, recoveryLock: recoveryLock);
    }

    throw const FormatException('Not a Lumaely key file');
  }

  /// Version written by this code.
  static const currentVersion = 1;

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
      'slots': [
        {
          'type': 'password',
          'kdf': 'argon2id13',
          'salt': base64Encode(passwordLock.salt),
          'opsLimit': passwordLock.opsLimit,
          'memLimit': passwordLock.memLimit,
          'cipher': 'xchacha20poly1305-ietf',
          'nonce': base64Encode(passwordLock.nonce),
          'cipherText': base64Encode(passwordLock.cipherText),
        },
        {
          'type': 'recovery',
          'cipher': 'xchacha20poly1305-ietf',
          'nonce': base64Encode(recoveryLock.nonce),
          'cipherText': base64Encode(recoveryLock.cipherText),
        },
      ],
    });
  }
}
