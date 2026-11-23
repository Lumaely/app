import 'package:lumaely_data/src/diary/master_key_cache.dart';

/// Thrown by a [MasterKeyCache] when the secure storage of the phone refuses
/// to keep the key (Keychain locked, Keystore failing...).
final class MasterKeyCacheException implements Exception {
  /// Creates the exception.
  const new();

  @override
  String toString() =>
      'MasterKeyCacheException: the secure storage refused the key';
}
