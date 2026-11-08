import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A master key locked by a recovery key.
@immutable
final class RecoveryLock {
  /// Creates a lock from its stored parts.
  const new({required this.nonce, required this.cipherText});

  /// Random bytes used once by XChaCha20-Poly1305.
  final Uint8List nonce;

  /// The encrypted master key.
  final Uint8List cipherText;
}
