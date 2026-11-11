import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';

void main() {
  final themes = {
    'Dawn': (LmThemeData.dawn, LmColors.dawn, Brightness.light),
    'Firefly': (LmThemeData.firefly, LmColors.firefly, Brightness.dark),
  };

  for (final MapEntry(key: name, value: (theme, colors, brightness))
      in themes.entries) {
    group(name, () {
      test('carries its colors', () {
        expect(theme.extension<LmTheme>()!.colors, same(colors));
        expect(theme.brightness, brightness);
        expect(theme.colorScheme.primary, colors.actionPrimary);
        expect(theme.scaffoldBackgroundColor, colors.background);
      });

      test('uses the design text styles, in the theme text color', () {
        final headline = theme.textTheme.headlineLarge!;
        expect(headline.fontFamily, LmTypography.headlineLarge.fontFamily);
        expect(headline.fontSize, LmTypography.headlineLarge.fontSize);
        expect(headline.color, colors.textPrimary);
      });
    });
  }

  test('lerp goes from one theme to the other', () {
    const dawn = LmTheme(colors: LmColors.dawn);
    const firefly = LmTheme(colors: LmColors.firefly);

    expect(dawn.lerp(firefly, 0).colors.background, LmColors.dawn.background);
    expect(
      dawn.lerp(firefly, 1).colors.background,
      LmColors.firefly.background,
    );
  });

  testWidgets('context.colors reads the colors of the current theme', (
    tester,
  ) async {
    late LmColors colors;

    await tester.pumpWidget(
      MaterialApp(
        theme: LmThemeData.firefly,
        home: Builder(
          builder: (context) {
            colors = context.colors;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(colors, same(LmColors.firefly));
  });
}
