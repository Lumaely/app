import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/remote.dart' show DriftRemoteException;
import 'package:lumaely_data/lumaely_data.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;
import 'package:test/test.dart';

/// 32 random bytes, like a real database key.
Uint8List randomKey() {
  final random = Random.secure();

  return Uint8List.fromList(
    List.generate(AppDatabase.keyLength, (_) => random.nextInt(256)),
  );
}

/// A wrong key surfaces as a SQLite error, sometimes wrapped by drift
/// because the database runs in another isolate.
final Matcher throwsWrongKey = throwsA(
  anyOf(
    isA<SqliteException>(),
    isA<DriftRemoteException>().having(
      (e) => e.remoteCause,
      'remoteCause',
      isA<SqliteException>(),
    ),
  ),
);

void main() {
  late Directory folder;
  late File file;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('lumaely__test_db_');
    file = File('${folder.path}/diary.db');
  });

  tearDown(() async {
    await folder.delete(recursive: true);
  });

  /// Opens the database, writes one row, and closes it.
  Future<void> writeStorageMode(Uint8List key) async {
    final db = AppDatabase.open(file, key);

    await db
        .into(db.databaseMeta)
        .insert(
          DatabaseMetaCompanion.insert(
            name: 'storage_mode',
            value: 'local_only',
          ),
        );

    await db.close();
  }

  test('reopens with the same key and finds the data', () async {
    final key = randomKey();
    await writeStorageMode(key);

    final db = AppDatabase.open(file, key);
    addTearDown(db.close);
    final rows = await db.select(db.databaseMeta).get();

    expect(rows.single.name, 'storage_mode');
    expect(rows.single.value, 'local_only');
  });

  test('refuses another key', () async {
    await writeStorageMode(randomKey());

    final db = AppDatabase.open(file, randomKey());
    addTearDown(db.close);

    await expectLater(db.select(db.databaseMeta).get(), throwsWrongKey);
  });

  test('the file on disk is not a readable SQLite file', () async {
    await writeStorageMode(randomKey());

    final bytes = await file.readAsBytes();
    final header = Uint8List.sublistView(bytes, 0, 16);
    final plainSqliteHeader = Uint8List.fromList(
      'SQLite format 3\u0000'.codeUnits,
    );

    expect(header, isNot(equals(plainSqliteHeader)));
  });

  test('refuses a key of the wrong size', () {
    expect(() => AppDatabase.open(file, Uint8List(16)), throwsArgumentError);
  });
}
