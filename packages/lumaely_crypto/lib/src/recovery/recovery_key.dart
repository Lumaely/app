import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:lumaely_crypto/src/recovery/word_list.dart';
import 'package:meta/meta.dart';

/// 256 random bits written as 24 words, to unlock a diary without its password.
@immutable
final class RecoveryKey {
  const new _(this._entropy);

  /// Builds the key from 32 random bytes.
  factory fromEntropy(Uint8List entropy) {
    if (entropy.length != entropyLength) {
      throw ArgumentError.value(entropy.length, 'entropy.length');
    }
    return RecoveryKey._(Uint8List.fromList(entropy));
  }

  /// Reads 24 words typed by a person. Spaces, line breaks and capitals
  /// don't matter.
  ///
  /// Throws [FormatException] for an unknown word, a wrong word count,
  /// or a typo caught by the checksum.
  factory parse(String text) {
    final words = text.toLowerCase().trim().split(RegExp(r'\s+'));
    if (words.length != wordCount) {
      throw FormatException('Expected $wordCount words, got ${words.length}');
    }

    var bits = BigInt.zero;
    for (var i = 0; i < words.length; i++) {
      final index = recoveryWordList.indexOf(words[i]);
      if (index == -1) {
        throw FormatException('Unknown word', words[i], i);
      }
      bits = (bits << 11) | BigInt.from(index);
    }

    final bytes = Uint8List(entropyLength + 1);
    for (var i = bytes.length - 1; i >= 0; i--) {
      bytes[i] = (bits & BigInt.from(0xFF)).toInt();
      bits = bits >> 8;
    }

    final entropy = Uint8List.sublistView(bytes, 0, entropyLength);
    if (_checksum(entropy) != bytes.last) {
      throw const FormatException('These words are not a valid recovery key');
    }
    return RecoveryKey._(Uint8List.fromList(entropy));
  }

  /// 32 bytes of randomness.
  static const entropyLength = 32;

  /// Number of words.
  static const wordCount = 24;

  final Uint8List _entropy;

  /// The 24 words, in order.
  List<String> get words {
    var bits = BigInt.zero;

    for (final byte in [..._entropy, _checksum(_entropy)]) {
      bits = (bits << 8) | BigInt.from(byte);
    }

    return List.generate(wordCount, (i) {
      final shift = 11 * (wordCount - 1 - i);
      final index = ((bits >> shift) & BigInt.from(0x7FF)).toInt();
      return recoveryWordList[index];
    });
  }

  /// A copy of the 32 bytes, to build the lock key.
  Uint8List extractEntropy() => Uint8List.fromList(_entropy);

  static int _checksum(Uint8List entropy) =>
      sha256.convert(entropy).bytes.first;

  @override
  bool operator ==(Object other) =>
      other is RecoveryKey && _sameBytes(other._entropy, _entropy);

  @override
  int get hashCode => Object.hashAll(_entropy);

  /// lil safety hack so that recovery key can't be logged or wtv
  @override
  String toString() => 'RecoveryKey(hidden)';

  static bool _sameBytes(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return false;
    }

    var diff = 0;

    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }

    return diff == 0;
  }
}
