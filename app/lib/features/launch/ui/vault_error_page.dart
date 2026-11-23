import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumaely/data/vault/vault.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// the vault could not be loaded (unreadable files, keychain error...)
/// - no error details: they could hold paths, and nobody can act on them
/// - retry reloads the vault; the router leaves this page once it works
class VaultErrorPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final retrying = ref.watch(vaultProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LmSpace.s6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: LmSpace.s4,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Your diary could not be opened',
                  textAlign: TextAlign.center,
                  style: LmTypography.headlineSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                'Nothing was lost. Try again, and restart your phone if it '
                'keeps happening.',
                textAlign: TextAlign.center,
                style: LmTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: LmSpace.s2),
              LmButton(
                label: 'Try again',
                loading: retrying,
                onPressed: retrying
                    ? null
                    : () => ref.invalidate(vaultProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
