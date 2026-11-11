import 'package:flutter/material.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'All colors',
  type: ColorTokens,
  path: '[Foundations]',
)
Widget allColors(BuildContext context) => const ColorTokens();

/// every color of the current theme, with its name and hex value
class ColorTokens extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(LmSpace.s4),
        children: [
          for (final MapEntry(key: name, value: color) in colors.all.entries)
            ListTile(
              leading: SizedBox.square(
                dimension: 40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(LmRadius.small),
                    border: Border.all(color: colors.border),
                  ),
                ),
              ),
              title: Text(name),
              subtitle: Text(_hex(color)),
            ),
        ],
      ),
    );
  }
}

String _hex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
