import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:material_ui/material_ui.dart';

/// big round icon above the title of a page with little on it (done, empty)
class LmIconBadge extends StatelessWidget {
  const new(this.icon, {super.key});

  final LmIcons icon;

  static const size = 88.0;
  static const iconSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
      child: LmIcon(icon, size: iconSize, color: colors.actionPrimary),
    );
  }
}
