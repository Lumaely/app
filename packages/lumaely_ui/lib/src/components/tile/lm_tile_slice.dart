import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:material_ui/material_ui.dart';

/// one row of a tile that is too long to be built at once (e.g. the journal)
/// - looks like LmTileGroup, but each row draws its own part of the tile
/// - [first] / [last]: rounded top / bottom; divider above all but the first
class LmTileSlice extends StatelessWidget {
  const new({
    required this.first,
    required this.last,
    required this.child,
    super.key,
  });

  final bool first;
  final bool last;

  /// usually an `LmTileRow`
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const radius = Radius.circular(LmRadius.tile);

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: first ? radius : Radius.zero,
          bottom: last ? radius : Radius.zero,
        ),
      ),
      clipBehavior: first || last ? Clip.antiAlias : Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [if (!first) const LmTileDivider(), child],
      ),
    );
  }
}

/// between two rows of a tile
class LmTileDivider extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: LmSpace.s4,
      endIndent: LmSpace.s4,
      color: context.colors.border,
    );
  }
}
