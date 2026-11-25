import 'package:lumaely_ui/src/components/tile/lm_tile.dart';
import 'package:lumaely_ui/src/components/tile/lm_tile_slice.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// look of the group title (size and color change together)
enum LmTileGroupTitleVariant {
  /// small grey label above settings-like groups, e.g. "Privacy"
  label,

  /// bigger dark heading above content, e.g. "October 2026" in the journal
  heading,
}

/// a list section: optional title, then the rows in one [LmTile]
/// - divider between rows only (not above the first, not under the last)
/// - space between groups is the screen's job
class LmTileGroup extends StatelessWidget {
  const new({
    required this.children,
    this.title,
    this.titleVariant = LmTileGroupTitleVariant.label,
    this.color,
    super.key,
  });

  /// e.g. "Privacy"; read as a heading by screen readers
  final String? title;

  final LmTileGroupTitleVariant titleVariant;

  /// usually `LmTileRow`s
  final List<Widget> children;

  /// fill of the tile, see [LmTile.color]
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final title = this.title;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) LmTileGroupTitle(title, variant: titleVariant),
        LmTile(
          color: color,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, row) in children.indexed) ...[
                if (index > 0) const LmTileDivider(),
                row,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// title above a group of rows, read as a heading by screen readers
class LmTileGroupTitle extends StatelessWidget {
  const new(
    this.text, {
    this.variant = LmTileGroupTitleVariant.label,
    super.key,
  });

  final String text;
  final LmTileGroupTitleVariant variant;

  /// gap between the title and the tile
  static const gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = switch (variant) {
      LmTileGroupTitleVariant.label => LmTypography.labelMedium.copyWith(
        color: colors.textSecondary,
      ),
      LmTileGroupTitleVariant.heading => LmTypography.titleMedium.copyWith(
        color: colors.textPrimary,
      ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(LmSpace.s4, 0, LmSpace.s4, gap),
      child: Semantics(header: true, child: Text(text, style: style)),
    );
  }
}
