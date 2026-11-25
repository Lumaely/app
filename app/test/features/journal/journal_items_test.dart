import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/features/journal/application/journal_items.dart';
import 'package:lumaely_core/lumaely_core.dart';

void main() {
  test('nothing written: no line', () {
    expect(journalItemsOf(const {}), isEmpty);
  });

  test('by month, newest first, with the ends of each month', () {
    final items = journalItemsOf({
      LocalDate(2026, 9, 30),
      LocalDate(2026, 10, 26),
      LocalDate(2026, 10, 29),
      LocalDate(2026, 10, 27),
      LocalDate(2025, 10, 29),
    });

    expect(items, [
      JournalMonth(LocalDate(2026, 10, 1)),
      JournalDay(LocalDate(2026, 10, 29), first: true, last: false),
      JournalDay(LocalDate(2026, 10, 27), first: false, last: false),
      JournalDay(LocalDate(2026, 10, 26), first: false, last: true),
      JournalMonth(LocalDate(2026, 9, 1)),
      JournalDay(LocalDate(2026, 9, 30), first: true, last: true),
      // same month, another year
      JournalMonth(LocalDate(2025, 10, 1)),
      JournalDay(LocalDate(2025, 10, 29), first: true, last: true),
    ]);
  });
}
