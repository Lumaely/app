import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:material_ui/material_ui.dart';

/// round icon button of the top bars
/// - [outlined]: bigger, with the action color, next to a main button
/// - [label] is what screen readers say, and the tooltip on hover
class LmIconButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    super.key,
  });

  final LmIcons icon;
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;

  static const size = 44.0;

  /// as high as an LmButton
  static const outlinedSize = 48.0;
  static const iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = outlined ? outlinedSize : LmIconButton.size;

    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      icon: LmIcon(icon, size: iconSize),
      style: IconButton.styleFrom(
        fixedSize: Size.square(size),
        minimumSize: Size.square(size),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        side: outlined && onPressed != null
            ? BorderSide(color: colors.actionPrimary, width: 1.5)
            : BorderSide(color: colors.border),
        shape: const CircleBorder(),
      ),
    );
  }
}
