import 'package:drift/drift.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_data/src/database/tables/entries.dart';
import 'package:lumaely_data/src/database/tables/sync_columns.dart';

/// The moods of each entry: one row per moment, or one for the whole day.
@DataClassName('EntryMoodRow')
class EntryMoods extends Table with SyncColumns {
  TextColumn get entryId => text().references(Entries, #id)();

  /// The moment's id (see [Moment.id]), or null for the whole day.
  ///
  /// Plain text on purpose: another device running a newer version of the
  /// app may sync moments this version does not know yet.
  TextColumn get moment => text().nullable()();

  /// From 1 to 5, checked by SQLite itself.
  // drift reads `score` here as "this column", not as a call: the lint is a
  // false positive for drift's documented way of writing a CHECK.
  // ignore: recursive_getters
  IntColumn get score => integer().check(score.isBetweenValues(1, 5))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {entryId, moment},
  ];
}
