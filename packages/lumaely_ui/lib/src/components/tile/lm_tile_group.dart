import 'package:flutter/material.dart';
import 'package:lumaely_ui/src/components/tile/lm_tile.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';

/// a list section: optional title, then the rows in one [LmTile]
/// - divider between rows only (not above the first, not under the last)
/// - space between groups is the screen's job
class LmTileGroup extends StatelessWidget {
  const new({required this.children, this.title, super.key});

  /// e.g. "Privacy"; read as a heading by screen readers
  final String? title;

  /// usually `LmTileRow`s
  final List<Widget> children;

  // from figma, not a token
  static const titleGap = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = this.title;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LmSpace.s4,
              0,
              LmSpace.s4,
              titleGap,
            ),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: LmTypography.titleMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        LmTile(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, row) in children.indexed) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: LmSpace.s4,
                    endIndent: LmSpace.s4,
                    color: colors.border,
                  ),
                row,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
