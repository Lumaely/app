import 'package:drift/drift.dart';

/// What a change did to a record.
enum ChangeOp {
  upsert('upsert'),
  delete('delete');

  new(this.id);

  /// Stored in the database. NEVER change an existing id.
  final String id;
}

/// Local changes the sync engine will push, in the order they happened.
///
/// Every write adds a row in the same transaction, and the sync engine will
/// remove the rows the server accepted.
@DataClassName('ChangeLogRow')
class ChangeLog extends Table {
  IntColumn get seq => integer().autoIncrement()();

  /// The changed record's table, e.g. `entries`.
  TextColumn get entity => text()();

  TextColumn get entityId => text()();

  TextColumn get op => text().map(const ChangeOpConverter())();

  /// When the change happened, in UTC.
  DateTimeColumn get at => dateTime()();
}

/// Stores a [ChangeOp] as its [ChangeOp.id].
class ChangeOpConverter extends TypeConverter<ChangeOp, String> {
  const new();

  @override
  ChangeOp fromSql(String fromDb) =>
      ChangeOp.values.firstWhere((op) => op.id == fromDb);

  @override
  String toSql(ChangeOp value) => value.id;
}
