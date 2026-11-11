import 'package:flutter/material.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'All text styles',
  type: TypographyTokens,
  path: '[Foundations]',
)
Widget allTextStyles(BuildContext context) {
  return TypographyTokens(
    sample: context.knobs.string(
      label: 'Sample',
      initialValue: 'How would you like to check in?',
    ),
  );
}

/// every text style, with its name and size, on a sample text
class TypographyTokens extends StatelessWidget {
  const new({required this.sample, super.key});

  final String sample;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(LmSpace.s4),
        children: [
          for (final MapEntry(key: name, value: style)
              in LmTypography.all.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: LmSpace.s6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: LmSpace.s1,
                children: [
                  Text(
                    '$name · ${style.fontSize?.toStringAsFixed(0)} px',
                    style: LmTypography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  Text(
                    sample,
                    style: style.copyWith(color: colors.textPrimary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
