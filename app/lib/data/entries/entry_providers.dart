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

/// The entry for [date], or null if there is none.
@riverpod
Stream<DayEntry?> dayEntry(Ref ref, LocalDate date) =>
    ref.watch(entryRepositoryProvider).watchDay(date);
