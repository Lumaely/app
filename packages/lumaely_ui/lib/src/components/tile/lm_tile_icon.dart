import 'package:flutter/material.dart';
import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';

/// small icon box at the start of a settings row (LmTileRow.leading)
/// - decorative: the row title says what it is
/// - icon in action primary, on the screen background
class LmTileIcon extends StatelessWidget {
  const new(this.icon, {super.key});

  final LmIcons icon;

  static const size = 28.0;
  static const iconSize = 18.0;

  // from figma, too small for a radius token (smallest is 12)
  static const radius = 7.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.all(Radius.circular(radius)),
        ),
        child: Center(
          child: LmIcon(icon, size: iconSize, color: colors.actionPrimary),
        ),
      ),
    );
  }
}
