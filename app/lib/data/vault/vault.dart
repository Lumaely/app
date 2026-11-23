import 'package:flutter/foundation.dart';
import 'package:lumaely/data/vault/vault_providers.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault.g.dart';

/// Creates, opens and unlocks the diary, and owns the one open [LocalDiary].
@Riverpod(keepAlive: true)
class Vault extends _$Vault {
  @override
  Future<VaultState> build() async {
    final files = ref.watch(diaryFilesProvider);

    if (!files.exists()) {
      return const VaultEmpty();
    }

    final diary = await LocalDiary.openFromCache(
      files: files,
      crypto: ref.watch(cryptoEngineProvider),
      cache: ref.watch(masterKeyCacheProvider),
    );

    return diary == null ? const VaultLocked() : await _opened(diary);
  }

  /// Creates the diary and opens it.
  ///
  /// Returns the recovery key, also kept in [VaultOpen.newRecoveryKey] until
  /// [confirmRecoveryKey]: it must be shown once, so the user can write it
  /// down.
  Future<RecoveryKey> create(String password) async {
    _expect<VaultEmpty>();

    final createdDiary = await LocalDiary.create(
      files: _files,
      password: password,
      crypto: _crypto,
      cache: _cache,
    );

    state = AsyncData(
      await _opened(
        createdDiary.diary,
        newRecoveryKey: createdDiary.recoveryKey,
      ),
    );
    return createdDiary.recoveryKey;
  }

  /// clears recovery key from memory and lets the app going on
  ///
  /// must be only called when we are sure user has written down the recovery
  /// key.
  Future<void> confirmRecoveryKey() async {
    final current = state.value;

    if (current is! VaultOpen || current.newRecoveryKey == null) {
      throw StateError('No new recovery key to confirm, got $current');
    }

    await current.diary.confirmRecoveryKey();
    state = AsyncData(VaultOpen(current.diary));
  }

  /// Throws [WrongSecretException] if the password is wrong
  Future<void> unlockWithPassword(String password) async {
    _expect<VaultLocked>();

    final diary = await LocalDiary.openWithPassword(
      files: _files,
      password: password,
      crypto: _crypto,
      cache: _cache,
    );

    state = AsyncData(await _opened(diary));
  }

  /// Throws [WrongSecretException] if the recovery key is wrong. The app should
  /// then ask for a new password.
  Future<void> unlockWithRecoveryKey(RecoveryKey recoveryKey) async {
    _expect<VaultLocked>();

    final diary = await LocalDiary.openWithRecoveryKey(
      files: _files,
      recoveryKey: recoveryKey,
      crypto: _crypto,
      cache: _cache,
    );

    await diary.confirmRecoveryKey();

    state = AsyncData(await _opened(diary));
  }

  /// debug builds only: puts the vault in error, to see the error page
  /// - closes an open diary first: the retry opens it again, and two open
  ///   at once would break the one-diary rule
  Future<void> debugSimulateError() async {
    assert(kDebugMode, 'debug builds only');

    if (state.value case VaultOpen(:final diary)) {
      await diary.close();
    }

    state = AsyncError(StateError('Simulated vault error'), StackTrace.current);
  }

  /// [diary] now belongs to the vault, which closes it
  /// - a recovery key never confirmed can't be shown again (the app was
  ///   closed before): a new one replaces it, to show now
  Future<VaultOpen> _opened(
    LocalDiary diary, {
    RecoveryKey? newRecoveryKey,
  }) async {
    ref.onDispose(diary.close);

    final unconfirmed =
        newRecoveryKey == null && !await diary.isRecoveryKeyConfirmed();

    return VaultOpen(
      diary,
      newRecoveryKey: unconfirmed
          ? await diary.replaceRecoveryKey()
          : newRecoveryKey,
    );
  }

  void _expect<T extends VaultState>() {
    if (state.value is! T) {
      throw StateError('Expected the vault to be $T, got ${state.value}');
    }
  }

  DiaryFiles get _files => ref.read(diaryFilesProvider);
  LmCryptoEngine get _crypto => ref.read(cryptoEngineProvider);
  MasterKeyCache get _cache => ref.read(masterKeyCacheProvider);
}
