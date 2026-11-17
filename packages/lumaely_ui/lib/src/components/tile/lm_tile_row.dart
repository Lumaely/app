import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// one line of a tile: [leading], [title], [subtitle], [value], chevron
/// - [onTap] null -> plain row, no chevron, no ripple
/// - read as one item by screen readers (one button when tappable)
/// - at least 48 high, texts wrap instead of being cut
/// - big text (1.5x and more): the value goes under the title, like ios
/// - needs a Material above it for the ink: put it in an LmTile / LmTileGroup
class LmTileRow extends StatefulWidget {
  const new({
    required this.title,
    this.subtitle,
    this.value,
    this.leading,
    this.onTap,
    super.key,
  });

  final String title;

  /// smaller line under the title
  final String? subtitle;

  /// current setting on the right, e.g. "Automatic"
  final String? value;

  /// icon or mood dot before the texts, e.g. LmTileIcon
  final Widget? leading;

  final VoidCallback? onTap;

  static const minHeight = 48.0;

  /// text scale from which the value goes under the title
  static const stackedTextScale = 1.5;

  // focus ring drawn inside the row (the tile clips what's outside)
  static const double focusInset = LmSpace.s1;
  static const double focusRadius = LmRadius.small;

  @override
  State<LmTileRow> createState() => _LmTileRowState();
}

class _LmTileRowState extends State<LmTileRow> {
  var _focused = false;

  @override
  void didUpdateWidget(LmTileRow old) {
    super.didUpdateWidget(old);

    if (widget.onTap == null) {
      _focused = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = widget.subtitle;
    final value = widget.value;
    final onTap = widget.onTap;

    // measured on the title size: android scales big fonts less than small
    final titleSize = LmTypography.bodyLarge.fontSize!;
    final scale = MediaQuery.textScalerOf(context).scale(titleSize) / titleSize;
    final stacked = scale >= LmTileRow.stackedTextScale;
    final valueStyle = LmTypography.bodyMedium.copyWith(
      color: colors.textSecondary,
    );

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: LmTileRow.minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LmSpace.s4,
          vertical: LmSpace.s3,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              spacing: LmSpace.s3,
              children: [
                ?widget.leading,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        widget.title,
                        style: LmTypography.bodyLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: LmTypography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      if (value != null && stacked)
                        Text(value, style: valueStyle),
                    ],
                  ),
                ),
                if (value != null && !stacked)
                  // at most half the row: a long value wraps, the title
                  // keeps some room
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth / 2,
                    ),
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: valueStyle,
                    ),
                  ),
                if (onTap != null)
                  LmIcon(
                    LmIcons.chevronRight,
                    size: 16,
                    color: colors.borderStrong,
                  ),
              ],
            );
          },
        ),
      ),
    );

    if (onTap == null) {
      return MergeSemantics(child: content);
    }

    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          onFocusChange: (focused) => setState(() => _focused = focused),
          // same overlays as the buttons, the ring replaces the focus fill
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colors.textPrimary.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return colors.textPrimary.withValues(alpha: 0.08);
            }
            return Colors.transparent;
          }),
          child: Stack(
            children: [
              content,
              if (_focused)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.all(LmTileRow.focusInset),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.focus, width: 2),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(LmTileRow.focusRadius),
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
    );
  }
}
