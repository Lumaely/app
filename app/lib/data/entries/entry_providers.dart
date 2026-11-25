import 'package:lumaely/data/vault/vault.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entry_providers.g.dart';

/// The open diary's entries.
///
/// Throws [StateError] if diary isn't open.
@riverpod
EntryRepository entryRepository(Ref ref) {
  final state = ref.watch(vaultProvider).value;

  if (state is! VaultOpen) {
    throw StateError('The diary is not open');
  }

  return state.diary.entries;
}

/// Every day that has an entry.
@riverpod
Stream<Set<LocalDate>> writtenDates(Ref ref) =>
    ref.watch(entryRepositoryProvider).watchDates();

/// The entry for [date], or null if there is none.
@riverpod
Stream<DayEntry?> dayEntry(Ref ref, LocalDate date) =>
    ref.watch(entryRepositoryProvider).watchDay(date);

/// The entries of the week from [monday] to Sunday, by date.
@riverpod
Stream<Map<LocalDate, DayEntry>> weekEntries(Ref ref, LocalDate monday) => ref
    .watch(entryRepositoryProvider)
    .watchRange(monday, monday.addDays(6))
    .map((entries) => {for (final entry in entries) entry.date: entry});
