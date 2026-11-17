import 'package:lumaely_ui/src/components/button/lm_button_style.dart';
import 'package:lumaely_ui/src/components/text_field/lm_input_decoration_theme.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_colors.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

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
      splashFactory: InkRipple.splashFactory,
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
      inputDecorationTheme: lmInputDecorationTheme(colors),
      // sheets and dialogs sit above the screen: surface raised, flat (no
      // shadow, no material tint)
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceRaised,
        modalBackgroundColor: colors.surfaceRaised,
        modalBarrierColor: colors.scrim,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(LmRadius.sheet),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        // drag handle: 48 px target, read "Dismiss" by screen readers
        showDragHandle: true,
        dragHandleColor: colors.borderStrong,
        dragHandleSize: const Size(40, 5),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceRaised,
        barrierColor: colors.scrim,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(LmRadius.dialog)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.actionPrimary,
        selectionColor: colors.actionPrimary.withValues(alpha: 0.3),
        selectionHandleColor: colors.actionPrimary,
      ),
      extensions: [LmTheme(colors: colors)],
    );
  }
}
