import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/data/entries/entry_providers.dart';
import 'package:lumaely_core/lumaely_core.dart';

import '../../helpers/fake_entry_repository.dart';

void main() {
  late FakeEntryRepository entries;
  late ProviderContainer container;

  const good = WholeDayMood(MoodScore.good);

  setUp(() {
    entries = FakeEntryRepository();
    container = ProviderContainer.test(
      overrides: [entryRepositoryProvider.overrideWithValue(entries)],
    );
  });

  test('a month at a time: its days only, oldest first', () async {
    final month = LocalDate(2026, 10, 1);
    for (final date in [
      LocalDate(2026, 9, 30),
      LocalDate(2026, 10, 1),
      LocalDate(2026, 10, 31),
      LocalDate(2026, 11, 1),
    ]) {
      await entries.save(date, moods: good);
    }

    final provider = entriesBetweenProvider(month, month.lastOfMonth);
    container.listen(provider, (_, _) {});
    final days = await container.read(provider.future);

    expect(days.keys, [LocalDate(2026, 10, 1), LocalDate(2026, 10, 31)]);
    expect(days[month]!.moods, good);
  });

  test(
    'the written dates change only when a day is added or deleted',
    () async {
      final date = LocalDate(2026, 10, 29);
      final changes = <Set<LocalDate>>[];
      container.listen(writtenDatesProvider, (_, next) {
        if (next.value case final dates?) changes.add(dates);
      });
      await container.read(writtenDatesProvider.future);

      await entries.save(date, moods: good);
      await entries.save(date, moods: good, journal: 'Long walk');
      await entries.delete(date);
      await pumpEventQueue();

      expect(changes, [
        isEmpty,
        {date},
        isEmpty,
      ]);
    },
  );
}
