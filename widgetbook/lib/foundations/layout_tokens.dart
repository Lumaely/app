import 'package:flutter/material.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Spacing and radii',
  type: LayoutTokens,
  path: '[Foundations]',
)
Widget spacingAndRadii(BuildContext context) => const LayoutTokens();

/// spacing scale as bars, and radii as boxes
class LayoutTokens extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(LmSpace.s4),
        children: [
          Text('Spacing', style: textTheme.titleMedium),
          const SizedBox(height: LmSpace.s3),
          for (final MapEntry(key: name, value: space) in LmSpace.all.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: LmSpace.s2),
              child: Row(
                children: [
                  SizedBox(width: 72, child: Text('$name · ${space.toInt()}')),
                  Container(
                    width: space,
                    height: LmSpace.s4,
                    color: colors.actionPrimary,
                  ),
                ],
              ),
            ),
          const SizedBox(height: LmSpace.s8),
          Text('Radii', style: textTheme.titleMedium),
          const SizedBox(height: LmSpace.s3),
          Wrap(
            spacing: LmSpace.s4,
            runSpacing: LmSpace.s4,
            children: [
              for (final MapEntry(key: name, value: radius)
                  in LmRadius.all.entries)
                Column(
                  spacing: LmSpace.s2,
                  children: [
                    SizedBox.square(
                      dimension: 72,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border.all(color: colors.borderStrong),
                          borderRadius: BorderRadius.circular(radius),
                        ),
                      ),
                    ),
                    Text('$name · ${radius.toInt()}'),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
