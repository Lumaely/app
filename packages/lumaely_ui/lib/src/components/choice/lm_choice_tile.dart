import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// big square button for choice lol (used in onboarding)
class LmChoiceTile extends StatefulWidget {
  const new({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    super.key,
  });

  final LmIcons icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  static const size = 228.0;
  static const double radius = LmRadius.dialog;

  static const iconBoxSize = 68.0;
  static const iconBoxRadius = 20.0;
  static const iconSize = 34.0;

  @override
  State<LmChoiceTile> createState() => _LmChoiceTileState();
}

class _LmChoiceTileState extends State<LmChoiceTile> {
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(LmChoiceTile.radius)),
    );

    final content = Padding(
      padding: const EdgeInsets.all(LmSpace.s5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: const BorderRadius.all(
                Radius.circular(LmChoiceTile.iconBoxRadius),
              ),
            ),
            child: SizedBox.square(
              dimension: LmChoiceTile.iconBoxSize,
              child: Center(
                child: LmIcon(
                  widget.icon,
                  size: LmChoiceTile.iconSize,
                  color: colors.actionPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: LmSpace.s4),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: LmTypography.titleLarge.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: LmTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      width: LmChoiceTile.size,
      child: MergeSemantics(
        child: Semantics(
          button: true,
          child: Material(
            color: colors.surface,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onFocusChange: (focused) => setState(() => _focused = focused),
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return colors.textPrimary.withValues(alpha: 0.12);
                }
                if (states.contains(WidgetState.hovered)) {
                  return colors.textPrimary.withValues(alpha: 0.08);
                }
                return Colors.transparent;
              }),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: LmChoiceTile.size),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    content,
                    if (_focused)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Padding(
                            padding: const EdgeInsets.all(LmSpace.s1),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colors.focus,
                                  width: 2,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    LmChoiceTile.radius - LmSpace.s1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
