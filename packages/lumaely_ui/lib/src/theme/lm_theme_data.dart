import 'package:flutter/material.dart';
import 'package:lumaely_ui/src/components/button/lm_button_style.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_colors.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';

abstract final class LmThemeData {
  /// light theme
  static final ThemeData dawn = _buildTheme(LmColors.dawn, Brightness.light);

  /// dark theme
  static final ThemeData firefly = _buildTheme(
    LmColors.firefly,
    Brightness.dark,
  );

  static ThemeData _buildTheme(LmColors colors, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.actionPrimary,
      onPrimary: colors.actionOnPrimary,
      secondary: colors.actionPrimary,
      onSecondary: colors.actionOnPrimary,
      error: colors.errorText,
      onError: colors.surface,
      surface: colors.background,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      surfaceContainerLowest: colors.surface,
      surfaceContainerLow: colors.surface,
      surfaceContainer: colors.surface,
      surfaceContainerHigh: colors.surfaceRaised,
      surfaceContainerHighest: colors.surfaceRaised,
      outline: colors.borderStrong,
      outlineVariant: colors.border,
    );

    const textTheme = TextTheme(
      displayLarge: LmTypography.displayLarge,
      displayMedium: LmTypography.displayMedium,
      displaySmall: LmTypography.displaySmall,
      headlineLarge: LmTypography.headlineLarge,
      headlineMedium: LmTypography.headlineMedium,
      headlineSmall: LmTypography.headlineSmall,
      titleLarge: LmTypography.titleLarge,
      titleMedium: LmTypography.titleMedium,
      titleSmall: LmTypography.titleSmall,
      bodyLarge: LmTypography.bodyLarge,
      bodyMedium: LmTypography.bodyMedium,
      bodySmall: LmTypography.bodySmall,
      labelLarge: LmTypography.labelLarge,
      labelMedium: LmTypography.labelMedium,
      labelSmall: LmTypography.labelSmall,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.border,
      textTheme: textTheme.apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: lmButtonStyle(
          colors,
          background: colors.actionPrimary,
          foreground: colors.actionOnPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: lmButtonStyle(
          colors,
          outline: colors.actionPrimary,
          foreground: colors.textPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: lmButtonStyle(colors, foreground: colors.textPrimary),
      ),
      extensions: [LmTheme(colors: colors)],
    );
  }
}
