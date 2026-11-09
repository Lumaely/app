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
    return diary == null ? const VaultLocked() : _opened(diary);
  }

  /// Creates the diary and opens it.
  ///
  /// Returns the recovery key. It must be shown once, so the user can write it
  /// down.
  Future<RecoveryKey> create(String password) async {
    _expect<VaultEmpty>();

    final createdDiary = await LocalDiary.create(
      files: _files,
      password: password,
      crypto: _crypto,
      cache: _cache,
    );

    state = AsyncData(_opened(createdDiary.diary));
    return createdDiary.recoveryKey;
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
    state = AsyncData(_opened(diary));
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
    state = AsyncData(_opened(diary));
  }

  VaultOpen _opened(LocalDiary diary) {
    ref.onDispose(diary.close);
    return VaultOpen(diary);
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
