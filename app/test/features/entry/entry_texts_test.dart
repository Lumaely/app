import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/features/entry/ui/entry_texts.dart';
import 'package:lumaely_core/lumaely_core.dart';

void main() {
  // a wednesday
  final today = LocalDate(2026, 10, 28);

  String name(LocalDate date) => entryDayName(date, today: today);

  test('the date has its year', () {
    expect(entryDateText(today), 'Wednesday, October 28, 2026');
  });

  test('today, a weekday during its own week, or that day', () {
    expect(name(today), 'today');
    expect(name(LocalDate(2026, 10, 27)), 'Tuesday');
    expect(name(LocalDate(2026, 10, 26)), 'Monday');
    // sunday of the week before
    expect(name(LocalDate(2026, 10, 25)), 'that day');
    expect(name(LocalDate(2021, 5, 2)), 'that day');
    // same weekday, another year
    expect(name(LocalDate(2025, 10, 28)), 'that day');
  });
}
