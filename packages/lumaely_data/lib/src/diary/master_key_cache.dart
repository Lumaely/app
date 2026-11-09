import 'dart:typed_data';

/// Keeps the unlocked master key on this device, so the diary opens without
/// a password every day.
///
/// The app implements it with the Keychain (iOS) or the Keystore (Android).
abstract interface class MasterKeyCache {
  /// The cached master key, or `null` if this device has none yet.
  Future<Uint8List?> read();

  /// Saves [masterKey] on this device.
  Future<void> write(Uint8List masterKey);

  /// Forgets the cached key (reset, sign out…).
  Future<void> clear();
}
