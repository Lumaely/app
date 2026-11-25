import 'package:lumaely_core/lumaely_core.dart';
import 'package:test/test.dart';

void main() {
  group('LocalDate', () {
    test('invalid dates', () {
      expect(() => LocalDate(2026, 2, 30), throwsArgumentError);
      expect(() => LocalDate(2026, 13, 1), throwsArgumentError);
    });

    test('accepts Feb 29 in a leap year only', () {
      expect(LocalDate(2028, 2, 29).toString(), '2028-02-29');
      expect(() => LocalDate(2027, 2, 29), throwsArgumentError);
    });

    test('parses & prints YYYY-MM-DD', () {
      final date = LocalDate.parse('2026-10-29');
      expect(date, LocalDate(2026, 10, 29));
      expect(date.toString(), '2026-10-29');
      expect(() => LocalDate.parse('29/10/2026'), throwsFormatException);
    });

    test('tryParse: null when it is not an existing date', () {
      expect(LocalDate.tryParse('2026-10-29'), LocalDate(2026, 10, 29));
      for (final text in ['2026-02-30', '2026-13-01', '29/10/2026', '']) {
        expect(LocalDate.tryParse(text), isNull, reason: text);
        expect(
          () => LocalDate.parse(text),
          throwsFormatException,
          reason: text,
        );
      }
    });

    test('today is the day shown on the device', () {
      final noon = DateTime(2026, 10, 29, 12);
      expect(LocalDate.today(noon.toUtc), LocalDate(2026, 10, 29));
    });

    test('toDateTime is the same day', () {
      final date = LocalDate(2026, 10, 29);
      expect(LocalDate.fromDateTime(date.toDateTime()), date);
    });

    test('date calculus & DST change', () {
      expect(LocalDate(2026, 10, 31).addDays(1), LocalDate(2026, 11, 1));
      expect(LocalDate(2026, 12, 31).addDays(1), LocalDate(2027, 1, 1));
      expect(LocalDate(2026, 3, 28).addDays(1), LocalDate(2026, 3, 29));
      expect(LocalDate(2026, 3, 29).addDays(1), LocalDate(2026, 3, 30));
      expect(LocalDate(2026, 3, 1).addDays(-1), LocalDate(2026, 2, 28));
    });

    test('first and last day of the month', () {
      LocalDate last(int year, int month, int day) =>
          LocalDate(year, month, day).lastOfMonth;

      expect(LocalDate(2026, 10, 29).firstOfMonth, LocalDate(2026, 10, 1));
      expect(last(2026, 10, 1), LocalDate(2026, 10, 31));
      expect(last(2026, 12, 31), LocalDate(2026, 12, 31));
      expect(last(2027, 2, 10), LocalDate(2027, 2, 28));
      expect(last(2028, 2, 10), LocalDate(2028, 2, 29));
    });

    test('counts days between two dates', () {
      expect(LocalDate(2026, 10, 29).daysSince(LocalDate(2020, 1, 1)), 2493);
    });

    test('comparaison by values', () {
      final a = LocalDate(2026, 10, 29);
      expect(a == LocalDate(2026, 10, 29), isTrue);
      expect(a.isBefore(LocalDate(2026, 10, 30)), isTrue);
      expect({a, LocalDate(2026, 10, 29)}.length, 1);
    });
  });
}
