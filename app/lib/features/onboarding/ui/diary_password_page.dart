import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumaely/data/vault/vault.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// password form page to create a new diary
class DiaryPasswordPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<DiaryPasswordPage> createState() => _DiaryPasswordPageState();
}

class _DiaryPasswordPageState extends ConsumerState<DiaryPasswordPage> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  var _triedOnce = false;
  var _creating = false;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  PasswordStrength get _strength => PasswordStrength.of(_password.text);

  bool get _matches => _confirmation.text == _password.text;

  Future<void> _continue() async {
    setState(() => _triedOnce = true);

    if (!_strength.isAccepted || !_matches) {
      return;
    }

    setState(() => _creating = true);

    try {
      await ref.read(vaultProvider.notifier).create(_password.text);
    } on Exception {
      if (!mounted) {
        return;
      }

      setState(() => _creating = false);

      await showLmDialog<void>(
        context,
        builder: (context) => LmDialog(
          title: 'Your diary could not be created',
          message: 'Nothing was saved. Try again in a moment.',
          actions: [
            LmButton(label: 'OK', onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final passwordError = !_triedOnce
        ? null
        : switch (_strength) {
            PasswordStrength.tooShort =>
              'Use at least ${PasswordStrength.minLength} characters.',
            PasswordStrength.weak => 'This password is too easy to guess.',
            _ => null,
          };
    final confirmationError = _triedOnce && !_matches
        ? 'The passwords don’t match.'
        : null;

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
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: LmIconButton(
                            icon: LmIcons.chevronLeft,
                            label: 'Back',
                            onPressed: _creating ? null : () => context.pop(),
                          ),
                        ),
                      ),
                      const SizedBox(height: LmSpace.s4),
                      Semantics(
                        header: true,
                        child: Text(
                          'Choose a diary password',
                          style: LmTypography.headlineLarge.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'It locks your diary on this phone.',
                        style: LmTypography.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: LmSpace.s4),
                      LmTextField(
                        label: 'Password',
                        controller: _password,
                        password: true,
                        error: passwordError,
                        enabled: !_creating,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: LmSpace.s2),
                      LmPasswordStrength(_strength),
                      const SizedBox(height: LmSpace.s4),
                      LmTextField(
                        label: 'Confirm password',
                        controller: _confirmation,
                        password: true,
                        error: confirmationError,
                        enabled: !_creating,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _continue(),
                      ),
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
                                  LmIcons.lock,
                                  size: 20,
                                  color: colors.textSecondary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Lumaely never sees this password and can’t '
                                  'reset it. Your recovery key, on the next '
                                  'step, can.',
                                  style: LmTypography.bodySmall.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: LmSpace.s4),
                      LmButton(
                        label: 'Continue',
                        large: true,
                        loading: _creating,
                        onPressed: _creating ? null : _continue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
