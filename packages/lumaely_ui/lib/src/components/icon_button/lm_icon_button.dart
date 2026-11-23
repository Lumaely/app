import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:material_ui/material_ui.dart';

/// icon button of the top bars
/// - 36 px circle, surface with a border, 20 px icon
/// - [label] is what screen readers say, and the tooltip on hover
class LmIconButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final LmIcons icon;
  final String label;
  final VoidCallback? onPressed;

  static const size = 36.0;
  static const iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      icon: LmIcon(icon, size: iconSize),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(size),
        minimumSize: const Size.square(size),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border),
        shape: const CircleBorder(),
      ),
    );
  }
}
