import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/app.dart';
import 'package:lumaely/data/vault/vault.dart';
import 'package:lumaely/data/vault/vault_state.dart';

/// a vault that loads whatever the test says, without files or keys
class FakeVault extends Vault {
  new(this.load);

  final Future<VaultState> Function() load;

  @override
  Future<VaultState> build() => load();

  void set(VaultState next) => state = AsyncData(next);
}

/// pumps the whole app on a [FakeVault] that loads with [load]
Future<FakeVault> launchApp(
  WidgetTester tester,
  Future<VaultState> Function() load,
) async {
  final vault = FakeVault(load);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [vaultProvider.overrideWith(() => vault)],
      child: const App(),
    ),
  );
  return vault;
}
