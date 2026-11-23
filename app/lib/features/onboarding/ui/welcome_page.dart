import 'package:go_router/go_router.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// first screen of a new install
class WelcomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned(left: 0, bottom: 0, child: LmCoverRise()),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 48, 28, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const LmLogo(),
                              const SizedBox(height: LmSpace.s6),
                              Semantics(
                                header: true,
                                child: Text(
                                  'Lumaely',
                                  style: LmTypography.displayLarge.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: LmSpace.s1),
                              Text(
                                'Your life. Decoded. Privately.',
                                style: LmTypography.headlineSmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            LmSpace.s5,
                            LmSpace.s6,
                            LmSpace.s5,
                            68,
                          ),
                          child: Center(
                            child: LmButton(
                              label: 'Get started',
                              large: true,
                              trailing: const LmIcon(
                                LmIcons.chevronRight,
                                size: 18,
                              ),
                              onPressed: () =>
                                  context.push(RouterPaths.onboardingStart),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
