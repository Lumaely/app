import 'package:drift/drift.dart';
import 'package:lumaely_core/lumaely_core.dart';

/// Stores a [LocalDate] in the following format: YYYY-MM-DD.
class LocalDateConverter extends TypeConverter<LocalDate, String> {
  const new();

  @override
  LocalDate fromSql(String fromDb) => LocalDate.parse(fromDb);

  @override
  String toSql(LocalDate value) => value.toString();
}
