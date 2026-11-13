import 'package:flutter/material.dart';
import 'package:lumaely_ui/src/components/button/lm_button_style.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';

/// button styles, from most to least visible
enum LmButtonVariant {
  /// main action of the screen (only one per screen)
  primary,

  /// alternative to the main action
  secondary,

  /// minor action, e.g. "Skip"
  text,

  /// main action but it deletes stuff
  /// e.g. "Delete my diary"
  danger,

  /// deletes stuff too, but not the main action
  dangerOutline,
}

/// Lumaely button
/// - [onPressed] null -> disabled
/// - [loading] -> spinner, presses are ignored (e.g. unlock, takes ~1s)
class LmButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.variant = LmButtonVariant.primary,
    this.large = false,
    this.loading = false,
    this.leading,
    this.trailing,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final LmButtonVariant variant;
  final bool large;
  final bool loading;

  /// icon before the label, same color as the label
  final Widget? leading;

  /// icon after the label ('>' lol)
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = switch (variant) {
      LmButtonVariant.primary => lmButtonStyle(
        colors,
        background: colors.actionPrimary,
        foreground: colors.actionOnPrimary,
        large: large,
      ),
      LmButtonVariant.secondary => lmButtonStyle(
        colors,
        outline: colors.actionPrimary,
        foreground: colors.textPrimary,
        large: large,
      ),
      LmButtonVariant.text => lmButtonStyle(
        colors,
        foreground: colors.textPrimary,
        large: large,
      ),
      LmButtonVariant.danger => lmButtonStyle(
        colors,
        background: colors.errorText,
        foreground: colors.actionOnPrimary,
        large: large,
      ),
      LmButtonVariant.dangerOutline => lmButtonStyle(
        colors,
        outline: colors.errorText,
        foreground: colors.errorText,
        large: large,
      ),
    };

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: LmSpace.s2,
      children: [?leading, Text(label), ?trailing],
    );

    final child = loading
        ? Stack(
            alignment: Alignment.center,
            children: [
              // invisible label: keeps the width
              // + screen readers still read it
              Opacity(opacity: 0, alwaysIncludeSemantics: true, child: content),
              SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: style.foregroundColor!.resolve(const {}),
                ),
              ),
            ],
          )
        : content;

    // not null on purpose: null would make it look disabled (grey)
    final action = loading && onPressed != null ? () {} : onPressed;

    return switch (variant) {
      LmButtonVariant.primary || LmButtonVariant.danger => FilledButton(
        onPressed: action,
        style: style,
        child: child,
      ),
      LmButtonVariant.secondary || LmButtonVariant.dangerOutline =>
        OutlinedButton(onPressed: action, style: style, child: child),
      LmButtonVariant.text => TextButton(
        onPressed: action,
        style: style,
        child: child,
      ),
    };
  }
}
