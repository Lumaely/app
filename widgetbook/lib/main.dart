import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:lumaely_widgetbook/main.directories.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() => runApp(const WidgetbookApp());

/// The catalog of Lumaely's design system.
@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      directories: directories,
      appBuilder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Material(child: child),
      ),
      addons: [
        ThemeAddon<ThemeData>(
          themes: [
            WidgetbookTheme(name: 'Dawn', data: LmThemeData.dawn),
            WidgetbookTheme(name: 'Firefly', data: LmThemeData.firefly),
          ],
          themeBuilder: (context, theme, child) => Theme(
            data: theme,
            child: ColoredBox(
              color: theme.scaffoldBackgroundColor,
              child: DefaultTextStyle(
                style: theme.textTheme.bodyMedium!,
                child: child,
              ),
            ),
          ),
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
