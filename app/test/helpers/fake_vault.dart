import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/app.dart';
import 'package:lumaely/data/vault/vault.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';

/// a vault that loads whatever the test says, without files or keys
/// - [onCreate]: what creating a diary does (it must open it)
class FakeVault extends Vault {
  new(this.load, {this.onCreate});

  final Future<VaultState> Function() load;
  final Future<VaultOpen> Function(String password)? onCreate;

  @override
  Future<VaultState> build() => load();

  @override
  Future<RecoveryKey> create(String password) async {
    final opened = await onCreate!(password);
    state = AsyncData(opened);
    return opened.newRecoveryKey!;
  }

  void set(VaultState next) => state = AsyncData(next);
}

/// pumps the whole app on a [FakeVault] that loads with [load]
Future<FakeVault> launchApp(
  WidgetTester tester,
  Future<VaultState> Function() load, {
  Future<VaultOpen> Function(String password)? onCreate,
}) async {
  final vault = FakeVault(load, onCreate: onCreate);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [vaultProvider.overrideWith(() => vault)],
      child: const App(),
    ),
  );
  return vault;
}
