import 'package:flutter/material.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'All icons', type: IconTokens, path: '[Foundations]')
Widget allIcons(BuildContext context) {
  return IconTokens(
    size: context.knobs.double.slider(
      label: 'Size',
      initialValue: 24,
      min: 16,
      max: 48,
    ),
  );
}

/// every icon of LmIcons with its name
class IconTokens extends StatelessWidget {
  const new({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: GridView.extent(
        padding: const EdgeInsets.all(LmSpace.s4),
        maxCrossAxisExtent: 112,
        mainAxisSpacing: LmSpace.s4,
        crossAxisSpacing: LmSpace.s4,
        children: [
          for (final icon in LmIcons.values)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: LmSpace.s2,
              children: [
                LmIcon(icon, size: size, color: colors.textPrimary),
                Text(
                  icon.name,
                  style: LmTypography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
