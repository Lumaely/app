import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A master key locked by a recovery key.
@immutable
final class RecoveryLock {
  /// Creates a lock from its stored parts.
  const new({required this.wrappedKey});

  /// The sealed master key: the 24-byte nonce, then the ciphertext and its
  /// tag (XChaCha20-Poly1305), as the cloud stores it.
  final Uint8List wrappedKey;
}
