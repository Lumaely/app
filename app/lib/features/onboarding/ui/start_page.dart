import 'package:go_router/go_router.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// new diary or existing one
/// - "I'm new" goes on to the diary password
/// - "I have a diary" comes with sync: for now a dialog says so
class StartPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            LmSpace.s5,
            LmSpace.s2,
            LmSpace.s5,
            LmSpace.s5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: LmIconButton(
                  icon: LmIcons.chevronLeft,
                  label: 'Back',
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(height: LmSpace.s4),
              Semantics(
                header: true,
                child: Text(
                  'Is this your first time with Lumaely?',
                  style: LmTypography.headlineLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose how you want to start.',
                style: LmTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: LmSpace.s10),
              Center(
                child: Column(
                  spacing: LmSpace.s4,
                  children: [
                    LmChoiceTile(
                      icon: LmIcons.sparkles,
                      title: 'I’m new',
                      description: 'Start a new diary.',
                      onTap: () => context.push(RouterPaths.onboardingPassword),
                    ),
                    LmChoiceTile(
                      icon: LmIcons.signIn,
                      title: 'I have a diary',
                      description: 'Sign in or connect your server.',
                      onTap: () => _showComingLater(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showComingLater(BuildContext context) {
    return showLmDialog<void>(
      context,
      builder: (context) => LmDialog(
        title: 'Coming later',
        message:
            'Signing in and connecting your own server come with sync. For '
            'now, Lumaely keeps your diary on this device.',
        actions: [
          LmButton(label: 'OK', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
