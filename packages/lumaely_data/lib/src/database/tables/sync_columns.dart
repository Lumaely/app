import 'package:drift/drift.dart';

/// Columns of every table that will sync with the server.
mixin SyncColumns on Table {
  /// UUIDv7 computed from the record's date (a keyed hash), or can be random.
  TextColumn get id => text()();

  /// When the record was first saved, in UTC.
  DateTimeColumn get createdAt => dateTime()();

  /// When the record was last saved, in UTC.
  DateTimeColumn get updatedAt => dateTime()();

  /// When the record was deleted, in UTC; null while it is alive.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// The last version the server confirmed; 0 until the first sync.
  IntColumn get serverVersion => integer().withDefault(const Constant(0))();
}
