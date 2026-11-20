import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely/core/router/vault_redirect.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely_data/lumaely_data.dart';

import '../../helpers/test_diary.dart';

void main() {
  late LocalDiary diary;

  setUpAll(() async => diary = await createTestDiary());

  const loading = AsyncLoading<VaultState>();
  final failed = AsyncError<VaultState>(StateError('test'), StackTrace.empty);
  const empty = AsyncData<VaultState>(VaultEmpty());
  const locked = AsyncData<VaultState>(VaultLocked());
  AsyncValue<VaultState> open() => AsyncData(VaultOpen(diary));

  // location -> where the redirect sends it (null: stays)
  void expectRedirects(
    AsyncValue<VaultState> vault,
    Map<String, String?> expected,
  ) {
    for (final MapEntry(key: location, value: target) in expected.entries) {
      expect(vaultRedirect(vault, location), target, reason: location);
    }
  }

  test('loading: the splash only', () {
    expectRedirects(loading, {
      RouterPaths.splash: null,
      RouterPaths.vaultError: RouterPaths.splash,
      RouterPaths.onboarding: RouterPaths.splash,
      RouterPaths.today: RouterPaths.splash,
    });
  });

  test('error: the error page only', () {
    expectRedirects(failed, {
      RouterPaths.vaultError: null,
      RouterPaths.splash: RouterPaths.vaultError,
      RouterPaths.unlock: RouterPaths.vaultError,
      RouterPaths.today: RouterPaths.vaultError,
    });
  });

  test('empty: onboarding and its steps only', () {
    expectRedirects(empty, {
      RouterPaths.onboarding: null,
      '${RouterPaths.onboarding}/password': null,
      RouterPaths.splash: RouterPaths.onboarding,
      RouterPaths.unlock: RouterPaths.onboarding,
      RouterPaths.today: RouterPaths.onboarding,
      // same start, other path
      '${RouterPaths.onboarding}-other': RouterPaths.onboarding,
    });
  });

  test('locked: unlock and its steps only', () {
    expectRedirects(locked, {
      RouterPaths.unlock: null,
      '${RouterPaths.unlock}/recovery-key': null,
      RouterPaths.splash: RouterPaths.unlock,
      RouterPaths.onboarding: RouterPaths.unlock,
      RouterPaths.today: RouterPaths.unlock,
      '${RouterPaths.unlock}ed': RouterPaths.unlock,
    });
  });

  test('open: anything but the splash, onboarding and unlock', () {
    expectRedirects(open(), {
      RouterPaths.today: null,
      '/journal': null,
      RouterPaths.splash: RouterPaths.today,
      RouterPaths.vaultError: RouterPaths.today,
      RouterPaths.onboarding: RouterPaths.today,
      '${RouterPaths.onboarding}/password': RouterPaths.today,
      RouterPaths.unlock: RouterPaths.today,
    });
  });

  test('the debug page is reachable in every state, in debug builds', () {
    for (final vault in [loading, failed, empty, locked, open()]) {
      expect(
        vaultRedirect(vault, RouterPaths.debug, debugBuild: true),
        isNull,
        reason: '$vault',
      );
    }
  });

  test('release builds: the debug path follows the usual rules', () {
    // (the route itself only exists in debug builds)
    expect(vaultRedirect(empty, RouterPaths.debug), RouterPaths.onboarding);
    expect(vaultRedirect(locked, RouterPaths.debug), RouterPaths.unlock);
  });
}
