import 'package:flutter/foundation.dart';
import 'package:lumaely_core/lumaely_core.dart';

/// One line of the journal list.
@immutable
sealed class JournalItem {
  const new();

  /// Its month, as the first day of it.
  LocalDate get month;
}

/// The title above the days of a month.
final class JournalMonth extends JournalItem {
  const new(this.month);

  @override
  final LocalDate month;

  @override
  bool operator ==(Object other) =>
      other is JournalMonth && other.month == month;

  @override
  int get hashCode => month.hashCode;
}

/// A written day, [first] and [last] of its month in the list.
final class JournalDay extends JournalItem {
  const new(this.date, {required this.first, required this.last});

  final LocalDate date;
  final bool first;
  final bool last;

  @override
  LocalDate get month => date.firstOfMonth;

  @override
  bool operator ==(Object other) =>
      other is JournalDay &&
      other.date == date &&
      other.first == first &&
      other.last == last;

  @override
  int get hashCode => Object.hash(date, first, last);
}

/// The lines of the list for these [dates], newest first.
///
/// Only dates: the days are read by the lines on screen.
List<JournalItem> journalItemsOf(Iterable<LocalDate> dates) {
  final days = dates.toList()..sort((a, b) => b.compareTo(a));
  final items = <JournalItem>[];

  for (final (index, day) in days.indexed) {
    final month = day.firstOfMonth;
    final first = index == 0 || days[index - 1].firstOfMonth != month;
    final last =
        index == days.length - 1 || days[index + 1].firstOfMonth != month;

    if (first) {
      items.add(JournalMonth(month));
    }
    items.add(JournalDay(day, first: first, last: last));
  }

  return items;
}
