import 'package:flutter/material.dart';
import 'package:lumaely_ui/src/tokens/lm_colors.dart';

/// Material theme with custom colors
final class LmTheme extends ThemeExtension<LmTheme> {
  const new({required this.colors});

  final LmColors colors;

  @override
  LmTheme copyWith({LmColors? colors}) {
    return LmTheme(colors: colors ?? this.colors);
  }

  @override
  LmTheme lerp(LmTheme? other, double t) {
    if (other == null) {
      return this;
    }
    return LmTheme(colors: LmColors.lerp(colors, other.colors, t));
  }
}

/// Shortcut to the colors of the current theme.
extension LmThemeContext on BuildContext {
  LmColors get colors => Theme.of(this).extension<LmTheme>()!.colors;
}
