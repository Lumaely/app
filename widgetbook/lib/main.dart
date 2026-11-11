import 'package:flutter/material.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:lumaely_widgetbook/main.directories.g.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() => runApp(const WidgetbookApp());

/// The catalog of Lumaely's design system.
@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Dawn', data: LmThemeData.dawn),
            WidgetbookTheme(name: 'Firefly', data: LmThemeData.firefly),
          ],
        ),
        ViewportAddon([
          IosViewports.iPhone13,
          IosViewports.iPhoneSE,
          AndroidViewports.samsungGalaxyS20,
          IosViewports.iPadPro11Inches,
        ]),
        TextScaleAddon(),
      ],
    );
  }
}
