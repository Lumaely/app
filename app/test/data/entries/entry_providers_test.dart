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

  test('the written months, each once, newest first', () async {
    for (final date in [
      LocalDate(2026, 9, 30),
      LocalDate(2026, 11, 2),
      LocalDate(2025, 11, 2),
      LocalDate(2026, 9, 1),
    ]) {
      await entries.save(date, moods: good);
    }
    container.listen(writtenMonthsProvider, (_, _) {});

    expect(await container.read(writtenMonthsProvider.future), [
      LocalDate(2026, 11, 1),
      LocalDate(2026, 9, 1),
      LocalDate(2025, 11, 1),
    ]);
  });

  test('the written months follow the diary', () async {
    final date = LocalDate(2026, 10, 29);
    container.listen(writtenMonthsProvider, (_, _) {});
    expect(await container.read(writtenMonthsProvider.future), isEmpty);

    await entries.save(date, moods: good);
    await pumpEventQueue();
    expect(await container.read(writtenMonthsProvider.future), [
      date.firstOfMonth,
    ]);

    await entries.delete(date);
    await pumpEventQueue();
    expect(await container.read(writtenMonthsProvider.future), isEmpty);
  });
}
