import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// one line of a tile: [leading], [title], [subtitle], [excerpt], [value],
/// chevron
/// - [onTap] null -> plain row, no chevron, no ripple
/// - read as one item by screen readers (one button when tappable)
/// - at least 48 high, texts wrap instead of being cut
/// - the value goes under the title when both don't fit on one line
/// - needs a Material above it for the ink: put it in an LmTile / LmTileGroup
class LmTileRow extends StatefulWidget {
  const new({
    required this.title,
    this.subtitle,
    this.excerpt,
    this.value,
    this.leading,
    this.semanticLabel,
    this.onTap,
    super.key,
  });

  final String title;

  /// smaller line under the title
  final String? subtitle;

  /// one more line under the subtitle, cut with … (e.g. start of a journal)
  final String? excerpt;

  /// current setting on the right, e.g. "Automatic"
  final String? value;

  /// icon or mood dot before the texts, e.g. LmTileIcon
  final Widget? leading;

  /// read instead of the texts by screen readers, when what's shown is not
  /// clear when spoken (e.g. "Oct 29" -> "October 29", "3.5/5" -> "3.5 of 5")
  final String? semanticLabel;

  final VoidCallback? onTap;

  static const minHeight = 48.0;

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
    final excerpt = widget.excerpt;
    final value = widget.value;
    final semanticLabel = widget.semanticLabel;
    final onTap = widget.onTap;

    final smallStyle = LmTypography.bodySmall.copyWith(
      color: colors.textSecondary,
    );

    final texts = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: LmTileRow.minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LmSpace.s4,
          vertical: LmSpace.s3,
        ),
        child: Row(
          spacing: LmSpace.s3,
          children: [
            ?widget.leading,
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: LmSpace.s3,
                runSpacing: 2,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: [
                      Text(
                        widget.title,
                        style: LmTypography.bodyLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) Text(subtitle, style: smallStyle),
                      if (excerpt != null)
                        Text(
                          excerpt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: smallStyle,
                        ),
                    ],
                  ),
                  if (value != null)
                    Text(
                      value,
                      style: LmTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              LmIcon(
                LmIcons.chevronRight,
                size: 16,
                color: colors.borderStrong,
              ),
          ],
        ),
      ),
    );

    final content = semanticLabel == null
        ? texts
        : Semantics(
            label: semanticLabel,
            child: ExcludeSemantics(child: texts),
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
