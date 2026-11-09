import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/src/database/app_database.dart';
import 'package:lumaely_data/src/diary/diary_files.dart';
import 'package:lumaely_data/src/diary/master_key_cache.dart';
import 'package:lumaely_data/src/exceptions/diary_already_exists_exception.dart';
import 'package:lumaely_data/src/exceptions/diary_not_found_exception.dart';
import 'package:lumaely_data/src/exceptions/wrong_database_key_exception.dart';

/// A newly created diary and the recovery key to show to the user, once.
typedef CreatedDiary = ({LocalDiary diary, RecoveryKey recoveryKey});

/// Represents an open diary
/// - its encrypted database
/// - its master key kept in memory while the diary is open
///
/// Note: Always [close] it when done.
final class LocalDiary {
  new _(this.database, this._masterKey, this._files, this._crypto);

  /// The encrypted database.
  final AppDatabase database;

  final SecureKey _masterKey;
  final DiaryFiles _files;
  final LmCryptoEngine _crypto;
  bool _closed = false;

  /// Creates a new diary in [files], locked with [password].
  ///
  /// Throws [DiaryAlreadyExistsException] if [files] already holds a diary.
  static Future<CreatedDiary> create({
    required DiaryFiles files,
    required String password,
    required LmCryptoEngine crypto,
    required MasterKeyCache cache,
  }) async {
    if (files.exists()) {
      throw const DiaryAlreadyExistsException();
    }

    final masterKey = crypto.generateMasterKey();
    LocalDiary? diary;

    try {
      final recoveryKey = crypto.generateRecoveryKey();

      await files.writeKeyFile(
        KeyFile(
          passwordLock: crypto.lockWithPassword(masterKey, password),
          recoveryLock: crypto.lockWithRecoveryKey(masterKey, recoveryKey),
        ),
      );

      diary = await _openDatabase(files, masterKey, crypto);
      await diary._recordCreation();
      await _cacheMasterKey(masterKey, cache);

      return (diary: diary, recoveryKey: recoveryKey);
    } catch (_) {
      if (diary != null) {
        await diary.close();
      } else {
        masterKey.dispose();
      }
      await files.delete();
      rethrow;
    }
  }

  /// Opens the diary with the master key cached on this device.
  ///
  /// Returns `null` if this device has no usable cached key (new phone,
  /// reinstall…): ask for the password or the recovery key instead.
  /// Throws [DiaryNotFoundException] if [files] contains no diary.
  static Future<LocalDiary?> openFromCache({
    required DiaryFiles files,
    required LmCryptoEngine crypto,
    required MasterKeyCache cache,
  }) async {
    _ensureExists(files);

    final bytes = await cache.read();
    if (bytes == null) {
      return null;
    }

    final SecureKey masterKey;
    try {
      masterKey = crypto.masterKeyFromBytes(bytes);
    } finally {
      bytes.fillRange(0, bytes.length, 0);
    }

    try {
      return await _openDatabase(files, masterKey, crypto);
    } on WrongDatabaseKeyException {
      masterKey.dispose();
      await cache.clear();
      return null;
    } catch (_) {
      masterKey.dispose();
      rethrow;
    }
  }

  /// Opens the diary with [password], then caches its master key on this
  /// device.
  ///
  /// Throws [WrongSecretException] if the password is wrong, and
  /// [DiaryNotFoundException] if [files] contains no diary.
  static Future<LocalDiary> openWithPassword({
    required DiaryFiles files,
    required String password,
    required LmCryptoEngine crypto,
    required MasterKeyCache cache,
  }) async {
    _ensureExists(files);

    final keyFile = await files.readKeyFile();
    final masterKey = crypto.unlockWithPassword(keyFile.passwordLock, password);

    return await _openAndCache(files, masterKey, crypto, cache);
  }

  /// Opens the diary with [recoveryKey], then caches its master key on this
  /// device. The app should then ask for a new password.
  ///
  /// Throws [WrongSecretException] if the recovery key is wrong, and
  /// [DiaryNotFoundException] if [files] contains no diary.
  static Future<LocalDiary> openWithRecoveryKey({
    required DiaryFiles files,
    required RecoveryKey recoveryKey,
    required LmCryptoEngine crypto,
    required MasterKeyCache cache,
  }) async {
    _ensureExists(files);

    final keyFile = await files.readKeyFile();
    final masterKey = crypto.unlockWithRecoveryKey(
      keyFile.recoveryLock,
      recoveryKey,
    );

    return await _openAndCache(files, masterKey, crypto, cache);
  }

  static void _ensureExists(DiaryFiles files) {
    if (!files.exists()) {
      throw const DiaryNotFoundException();
    }
  }

  /// Closes the database and wipes the master key from memory.
  Future<void> close() async {
    if (_closed) {
      return;
    }

    _closed = true;
    await database.close();
    _masterKey.dispose();
  }

  /// Replaces the password, after checking [currentPassword].
  ///
  /// The recovery key and the database don't change.
  /// Throws [WrongSecretException] if [currentPassword] is wrong.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _ensureOpen();

    final keyFile = await _files.readKeyFile();

    _crypto.unlockWithPassword(keyFile.passwordLock, currentPassword).dispose();
    await _lockWithNewPassword(keyFile, newPassword);
  }

  /// Sets a new password without asking for the old one.
  ///
  /// Only for right after [openWithRecoveryKey], when the person has
  /// proven who they are with the recovery key.
  Future<void> setPasswordAfterRecovery(String newPassword) async {
    _ensureOpen();

    await _lockWithNewPassword(await _files.readKeyFile(), newPassword);
  }

  static Future<LocalDiary> _openDatabase(
    DiaryFiles files,
    SecureKey masterKey,
    LmCryptoEngine crypto,
  ) async {
    final databaseKey = crypto.deriveKey(masterKey, KeyPurpose.database);
    final keyBytes = databaseKey.extractBytes();

    try {
      final database = await AppDatabase.open(files.database, keyBytes);
      return LocalDiary._(database, masterKey, files, crypto);
    } finally {
      keyBytes.fillRange(0, keyBytes.length, 0);
      databaseKey.dispose();
    }
  }

  static Future<void> _cacheMasterKey(
    SecureKey masterKey,
    MasterKeyCache cache,
  ) async {
    final bytes = masterKey.extractBytes();

    try {
      await cache.write(bytes);
    } finally {
      bytes.fillRange(0, bytes.length, 0);
    }
  }

  static Future<LocalDiary> _openAndCache(
    DiaryFiles files,
    SecureKey masterKey,
    LmCryptoEngine crypto,
    MasterKeyCache cache,
  ) async {
    LocalDiary? diary;

    try {
      diary = await _openDatabase(files, masterKey, crypto);
      await _cacheMasterKey(masterKey, cache);
      return diary;
    } catch (_) {
      if (diary != null) {
        await diary.close();
      } else {
        masterKey.dispose();
      }
      rethrow;
    }
  }

  Future<void> _lockWithNewPassword(KeyFile keyFile, String newPassword) async {
    final passwordLock = _crypto.lockWithPassword(_masterKey, newPassword);
    await _files.writeKeyFile(keyFile.withPasswordLock(passwordLock));
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('This diary is closed');
    }
  }

  Future<void> _recordCreation() async {
    await database.batch((batch) {
      batch.insertAll(database.databaseMeta, [
        DatabaseMetaCompanion.insert(name: 'storage_mode', value: 'local_only'),
        DatabaseMetaCompanion.insert(
          name: 'created_at',
          value: DateTime.now().toUtc().toIso8601String(),
        ),
      ]);
    });
  }
}
