import 'package:drift/drift.dart';
import 'package:lumaely_data/src/database/converters/local_date_converter.dart';
import 'package:lumaely_data/src/database/tables/sync_columns.dart';

/// One row per day the user recorded.
@DataClassName('EntryRow')
class Entries extends Table with SyncColumns {
  /// The day of the entry.
  TextColumn get day => text().map(const LocalDateConverter()).unique()();

  /// True -> one mood for the whole day. False -> one mood per moment.
  BoolColumn get wholeDay => boolean()();

  /// The entry's journal text.
  TextColumn get journal => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
