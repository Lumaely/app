import 'package:drift/drift.dart';

/// Information about the database: storage mode, creation date…
class DatabaseMeta extends Table {
  /// Name of the info, e.g. `storage_mode`.
  TextColumn get name => text()();

  /// Its value, as text.
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}
