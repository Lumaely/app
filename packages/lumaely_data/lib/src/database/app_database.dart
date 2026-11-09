import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:lumaely_data/src/database/tables/database_meta.dart';
import 'package:meta/meta.dart';

part 'app_database.g.dart';

/// Lumaely's local database.
///
/// In the app it is always opened encrypted with [AppDatabase.open].
/// Call [close] before deleting or replacing its file.
@DriftDatabase(tables: [DatabaseMeta])
class AppDatabase extends _$AppDatabase {
  new _(super.e);

  /// Opens the encrypted database stored in [file], creating it if needed.
  ///
  /// The first query fails if [databaseKey] is wrong or if SQLite
  /// cannot encrypt.
  factory open(File file, Uint8List databaseKey) {
    return AppDatabase._(_encryptedExecutor(file, databaseKey));
  }

  /// An unencrypted database in memory, for tests of queries and
  /// repositories.
  @visibleForTesting
  factory inMemory() => AppDatabase._(NativeDatabase.memory());

  /// Size in bytes of the database key.
  static const keyLength = 32;

  /// Version of the database schema. Used for versioning, migration purposes.
  @override
  int get schemaVersion => 1;

  static QueryExecutor _encryptedExecutor(File file, Uint8List databaseKey) {
    if (databaseKey.length != keyLength) {
      throw ArgumentError.value(
        databaseKey.length,
        'databaseKey.length',
        'A database key is $keyLength bytes',
      );
    }

    final keyHex = databaseKey
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    return NativeDatabase.createInBackground(
      file,
      setup: (database) {
        database.execute("PRAGMA key = 'raw:$keyHex';");

        final cipher = database.select('PRAGMA cipher;');

        if (cipher.isEmpty) {
          throw StateError('This SQLite build cannot encrypt');
        }

        // check if key is wrong by reading a line (sqlite3mc only throws error
        // when reading, not when giving the key)
        database.select('SELECT count(*) FROM sqlite_master;');
      },
    );
  }
}
