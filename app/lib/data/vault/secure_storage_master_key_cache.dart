import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lumaely_data/lumaely_data.dart';

/// [MasterKeyCache] kept in the iOS Keychain or the Android Keystore.
class SecureStorageMasterKeyCache implements MasterKeyCache {
  /// Uses [storage] if given (which is the case in tests).
  /// Otherwise, uses the platform's secure storage otherwise.
  new({ FlutterSecureStorage? storage })
      : _storage = storage ??
      const FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  @visibleForTesting
  static const entryName = 'lumaely.master_key.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<Uint8List?> read() async {
    try {
      final encoded = await _storage.read(key: entryName);

      return encoded == null ? null : base64Decode(encoded);
    } on PlatformException {
      // unreadable entry --> e.g. restored from another phone's backup
      await clear();
      return null;
    } on FormatException {
      // not base64
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(Uint8List masterKey) =>
      _storage.write(key: entryName, value: base64Encode(masterKey));

  @override
  Future<void> clear() => _storage.delete(key: entryName);
}
