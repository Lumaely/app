import 'package:flutter/material.dart';
import 'package:lumaely_ui/src/tokens/lm_colors.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';

/// style shared by all the buttons (also used by the theme)
/// pill, 48 high (56 if [large])
///
/// no [background] and no [outline] -> text button
ButtonStyle lmButtonStyle(
  LmColors colors, {
  required Color foreground,
  Color? background,
  Color? outline,
  bool large = false,
}) {
  final content = WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) {
      return colors.textDisabled;
    }
    return foreground;
  });

  return ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(64, large ? 56 : 48)),
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: large ? LmSpace.s10 : LmSpace.s6),
    ),
    // macOS makes buttons smaller by default
    visualDensity: VisualDensity.standard,
    shape: const WidgetStatePropertyAll(StadiumBorder()),
    textStyle: WidgetStatePropertyAll(
      large ? LmTypography.titleMedium : LmTypography.labelLarge,
    ),
    iconSize: const WidgetStatePropertyAll(18),
    foregroundColor: content,
    iconColor: content,
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (background == null) {
        return Colors.transparent;
      }
      if (states.contains(WidgetState.disabled)) {
        return colors.border;
      }
      return background;
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return foreground.withValues(alpha: 0.12);
      }
      if (states.contains(WidgetState.hovered)) {
        return foreground.withValues(alpha: 0.08);
      }
      return null;
    }),
    side: WidgetStateProperty.resolveWith((states) {
      // keyboard / switch access focus ring, drawn outside
      if (states.contains(WidgetState.focused)) {
        return BorderSide(
          color: colors.focus,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        );
      }
      if (outline == null) {
        return null;
      }
      final disabled = states.contains(WidgetState.disabled);
      return BorderSide(color: disabled ? colors.border : outline, width: 1.5);
    }),
  );
}
