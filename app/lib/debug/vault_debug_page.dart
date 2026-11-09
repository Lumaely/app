import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumaely/data/vault/vault.dart';
import 'package:lumaely/data/vault/vault_providers.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';

/// Temporary screen to try the vault on a real device. Not part of the app.
class VaultDebugPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<VaultDebugPage> createState() => _VaultDebugPageState();
}

class _VaultDebugPageState extends ConsumerState<VaultDebugPage> {
  final _password = TextEditingController();
  final _recoveryKey = TextEditingController();
  var _busy = false;
  String? _message;

  @override
  void dispose() {
    _password.dispose();
    _recoveryKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vault = ref.watch(vaultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vault debug')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            switch (vault) {
              AsyncData(:final value) => Text(
                'State: ${value.runtimeType}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AsyncError(:final error) => Text('Error: $error'),
              _ => const LinearProgressIndicator(),
            },
            if (_busy) const LinearProgressIndicator(),
            ...switch (vault.value) {
              VaultEmpty() => _emptyActions(),
              VaultLocked() => _lockedActions(),
              VaultOpen(:final diary) => _openActions(diary),
              null => const <Widget>[],
            },
            if (_message case final message?) SelectableText(message),
          ],
        ),
      ),
    );
  }

  List<Widget> _emptyActions() => [
    _passwordField(),
    _button('Create diary', _create),
  ];

  List<Widget> _lockedActions() => [
    _passwordField(),
    _button('Unlock with password', _unlockWithPassword),
    TextField(
      controller: _recoveryKey,
      decoration: const InputDecoration(labelText: 'Recovery key'),
      maxLines: 3,
    ),
    _button('Unlock with recovery key', _unlockWithRecoveryKey),
    _button('Delete diary', _deleteDiary),
  ];

  List<Widget> _openActions(LocalDiary diary) => [
    _button('Read database', () => _readDatabase(diary)),
    _button('Simulate restart', _restart),
    _button('Forget key on this device', _forgetKey),
    _button('Delete diary', _deleteDiary),
  ];

  Widget _passwordField() => TextField(
    controller: _password,
    decoration: const InputDecoration(labelText: 'Password'),
    obscureText: true,
  );

  Widget _button(String label, Future<String?> Function() action) =>
      FilledButton(
        onPressed: _busy ? null : () => _run(label, action),
        child: Text(label),
      );

  /// Runs [action], then shows how long it took and what it returned.
  Future<void> _run(String label, Future<String?> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final stopwatch = Stopwatch()..start();

    String message;
    try {
      final detail = await action();
      message = '$label: OK in ${stopwatch.elapsedMilliseconds} ms';
      if (detail != null) message += '\n\n$detail';
    } on WrongSecretException {
      message = '$label: wrong password or recovery key';
    } on Object catch (error) {
      message = '$label failed: $error';
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = message;
    });
  }

  Future<String?> _create() async {
    final recoveryKey = await ref
        .read(vaultProvider.notifier)
        .create(_password.text);
    final words = recoveryKey.words.join(' ');
    // Debug only: the real app must never put the recovery key in the
    // clipboard, which other apps can read.
    await Clipboard.setData(ClipboardData(text: words));
    return 'Recovery key (copied):\n$words';
  }

  Future<String?> _unlockWithPassword() async {
    await ref.read(vaultProvider.notifier).unlockWithPassword(_password.text);
    return null;
  }

  Future<String?> _unlockWithRecoveryKey() async {
    final recoveryKey = RecoveryKey.parse(_recoveryKey.text);
    await ref.read(vaultProvider.notifier).unlockWithRecoveryKey(recoveryKey);
    return null;
  }

  Future<String?> _readDatabase(LocalDiary diary) async {
    final database = diary.database;
    final rows = await database.select(database.databaseMeta).get();
    return rows.map((row) => '${row.name} = ${row.value}').join('\n');
  }

  /// Closes the diary and rebuilds the vault, like an app restart.
  Future<String?> _restart() async {
    if (ref.read(vaultProvider).value case VaultOpen(:final diary)) {
      await diary.close();
    }
    ref.invalidate(vaultProvider);
    await ref.read(vaultProvider.future);
    return null;
  }

  /// Like a new phone: the files stay, the Keychain entry goes.
  Future<String?> _forgetKey() async {
    await ref.read(masterKeyCacheProvider).clear();
    return await _restart();
  }

  Future<String?> _deleteDiary() async {
    if (ref.read(vaultProvider).value case VaultOpen(:final diary)) {
      await diary.close();
    }
    await ref.read(diaryFilesProvider).delete();
    return await _restart();
  }
}
