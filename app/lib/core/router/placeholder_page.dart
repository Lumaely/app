import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

class PlaceholderPage extends StatelessWidget {
  const new({required this.title, this.action, super.key});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                  title,
                  textAlign: TextAlign.center,
                  style: LmTypography.headlineSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              ?action,
              if (kDebugMode)
                LmButton(
                  label: 'Vault debug page',
                  variant: LmButtonVariant.secondary,
                  onPressed: () => context.go(RouterPaths.debug),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
