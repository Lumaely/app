import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:lumaely_data/src/database/tables/database_meta.dart';
import 'package:lumaely_data/src/exceptions/wrong_database_key_exception.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

part 'app_database.g.dart';

/// Lumaely's local database.
///
/// In the app it is always opened encrypted with [AppDatabase.open].
/// Call [close] before deleting or replacing its file.
@DriftDatabase(tables: [DatabaseMeta])
class AppDatabase extends _$AppDatabase {
  new _(super.e);

  /// An unencrypted database in memory, for tests of queries and
  /// repositories.
  @visibleForTesting
  factory inMemory() => AppDatabase._(NativeDatabase.memory());

  /// Opens the encrypted database stored in [file], creating it if needed.
  ///
  /// Throws [WrongDatabaseKeyException] if [databaseKey] does not open an
  /// existing file, and [StateError] if SQLite cannot encrypt.
  static Future<AppDatabase> open(File file, Uint8List databaseKey) async {
    final keyHex = _toHex(databaseKey);

    _checkKey(file, keyHex);

    return AppDatabase._(
      NativeDatabase.createInBackground(
        file,
        setup: (database) => _applyKey(database, keyHex),
      ),
    );
  }

  /// Size in bytes of the database key.
  static const keyLength = 32;

  /// Version of the database schema. Used for versioning, migration purposes.
  @override
  int get schemaVersion => 1;

  /// SQLite's internal code for "file is not a database", returned for a wrong
  /// key.
  static const _sqliteNotADatabase = 26;

  static void _applyKey(Database database, String keyHex) {
    database.execute("PRAGMA key = 'raw:$keyHex';");
  }

  /// Opens [file] briefly, in this isolate, to check encryption and the key.
  static void _checkKey(File file, String keyHex) {
    final database = sqlite3.open(file.path);

    try {
      _applyKey(database, keyHex);

      if (database.select('PRAGMA cipher;').isEmpty) {
        throw StateError('This SQLite build cannot encrypt');
      }

      try {
        // check if key is wrong by reading a line (sqlite3mc only throws error
        // when reading, not when giving the key)
        database.select('SELECT count(*) FROM sqlite_master;');
      } on SqliteException catch (error) {
        if (error.resultCode == _sqliteNotADatabase) {
          throw const WrongDatabaseKeyException();
        }
        rethrow;
      }
    } finally {
      database.close();
    }
  }

  static String _toHex(Uint8List databaseKey) {
    if (databaseKey.length != keyLength) {
      throw ArgumentError.value(
        databaseKey.length,
        'databaseKey.length',
        'A database key is $keyLength bytes',
      );
    }

    return databaseKey
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
