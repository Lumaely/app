import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely/data/vault/vault_state.dart';

/// where the app must go for this vault state, or null to stay on [location]
/// - pure: tested as a table (vault state x path)
/// - error: the error page, also while it retries
/// - loading: the splash
/// - empty: onboarding only, locked: unlock only
/// - open: anything but the splash, onboarding and unlock
/// - [debugBuild]: the debug page is reachable in every state
String? vaultRedirect(
  AsyncValue<VaultState> vault,
  String location, {
  bool debugBuild = false,
}) {
  if (debugBuild && location == RouterPaths.debug) {
    return null;
  }

  if (vault.hasError) {
    return _goTo(RouterPaths.vaultError, location);
  }

  // the last state while it reloads
  final state = vault.value;

  if (state == null) {
    return _goTo(RouterPaths.splash, location);
  }

  return switch (state) {
    VaultEmpty() =>
      _isIn(location, RouterPaths.onboarding) ? null : RouterPaths.onboarding,
    VaultLocked() =>
      _isIn(location, RouterPaths.unlock) ? null : RouterPaths.unlock,
    VaultOpen() =>
      location == RouterPaths.splash ||
              location == RouterPaths.vaultError ||
              _isIn(location, RouterPaths.onboarding) ||
              _isIn(location, RouterPaths.unlock)
          ? RouterPaths.today
          : null,
  };
}

String? _goTo(String target, String location) =>
    location == target ? null : target;

bool _isIn(String location, String base) =>
    location == base || location.startsWith('$base/');
