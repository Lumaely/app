import 'package:flutter/material.dart';
import 'package:lumaely_ui/src/tokens/lm_colors.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';

/// look of all text fields (also used by the theme)
/// - white box, thin border
/// - focused -> 2px in the focus color
/// - error -> 2px in the error color
InputDecorationThemeData lmInputDecorationTheme(LmColors colors) {
  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(LmRadius.field),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecorationThemeData(
    filled: true,
    fillColor: colors.surface,
    // no grey tint when the mouse is over it
    hoverColor: colors.surface,
    contentPadding: const EdgeInsets.all(LmSpace.s4),
    hintStyle: LmTypography.bodyMedium.copyWith(color: colors.textSecondary),
    errorStyle: LmTypography.bodySmall.copyWith(color: colors.errorText),
    counterStyle: LmTypography.bodySmall.copyWith(color: colors.textSecondary),
    border: border(colors.borderStrong),
    enabledBorder: border(colors.borderStrong),
    disabledBorder: border(colors.border),
    focusedBorder: border(colors.focus, 2),
    errorBorder: border(colors.errorText, 2),
    focusedErrorBorder: border(colors.errorText, 2),
  );
}
