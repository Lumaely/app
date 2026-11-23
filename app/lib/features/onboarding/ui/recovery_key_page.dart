import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumaely/data/vault/vault.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// the recovery key of a new diary, shown once
/// - its words come from the vault (VaultOpen.newRecoveryKey), only in memory
/// - no back button: the diary exists now; "?" explains why the key matters
/// - Continue asks for the box, then "Did you save your key?"; yes confirms
///   it and the router moves on to Today
class RecoveryKeyPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RecoveryKeyPage> createState() => _RecoveryKeyPageState();
}

class _RecoveryKeyPageState extends ConsumerState<RecoveryKeyPage> {
  var _saved = false;
  var _triedOnce = false;
  var _confirming = false;

  Future<void> _showWhy() {
    return showLmSheet<void>(
      context,
      builder: (context) => LmSheet(
        title: 'Why your recovery key matters',
        message:
            'Your password seals your diary’s key. Lumaely never knows it, so '
            'it can’t reset it for you. If you forget the password, only your '
            'recovery key opens your diary. Without both, nobody can open '
            'it, not even us.',
        actions: [
          LmButton(label: 'Got it', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Future<void> _continue() async {
    setState(() => _triedOnce = true);

    if (!_saved) {
      return;
    }

    final confirmed = await showLmDialog<bool>(
      context,
      builder: (context) => LmDialog(
        title: 'Did you save your key?',
        message:
            'Without it, a forgotten password means your diary is lost for '
            'good. Nobody can recover it.',
        actions: [
          LmButton(
            label: 'Yes, I saved it',
            onPressed: () => Navigator.pop(context, true),
          ),
          LmButton(
            label: 'Go back',
            variant: LmButtonVariant.text,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _confirming = true);

    try {
      await ref.read(vaultProvider.notifier).confirmRecoveryKey();
    } on Exception {
      if (!mounted) {
        return;
      }

      setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final recoveryKey = switch (ref.watch(vaultProvider).value) {
      VaultOpen(:final newRecoveryKey?) => newRecoveryKey,
      _ => null,
    };

    // confirmed: the router is about to leave this page
    if (recoveryKey == null) {
      return const Scaffold();
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              LmSpace.s5,
              LmSpace.s2,
              LmSpace.s5,
              LmSpace.s5,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - LmSpace.s2 - LmSpace.s5,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: LmIconButton(
                          icon: LmIcons.help,
                          label: 'Why it matters',
                          onPressed: _showWhy,
                        ),
                      ),
                    ),
                    const SizedBox(height: LmSpace.s4),
                    Semantics(
                      header: true,
                      child: Text(
                        'Save your recovery key',
                        style: LmTypography.headlineLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'If you forget your password, this key is the only way '
                      'back into your diary.',
                      style: LmTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: LmSpace.s4),
                    LmRecoveryKeyWords(recoveryKey.words),
                    const SizedBox(height: LmSpace.s4),
                    LmTile(
                      child: Padding(
                        padding: const EdgeInsets.all(LmSpace.s4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: LmSpace.s3,
                          children: [
                            LmLineMark(
                              style: LmTypography.bodySmall,
                              size: 20,
                              child: LmIcon(
                                LmIcons.info,
                                size: 20,
                                color: colors.textSecondary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Write it on paper or in your password '
                                'manager, and keep it offline. Lumaely shows '
                                'it only once.',
                                style: LmTypography.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: LmSpace.s2),
                    LmCheckboxRow(
                      label: 'I saved my recovery key somewhere safe',
                      value: _saved,
                      onChanged: (saved) => setState(() => _saved = saved),
                      error: _triedOnce && !_saved
                          ? 'Check the box once your key is saved.'
                          : null,
                    ),
                    const Spacer(),
                    const SizedBox(height: LmSpace.s4),
                    LmButton(
                      label: 'Continue',
                      large: true,
                      loading: _confirming,
                      onPressed: _confirming ? null : _continue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
