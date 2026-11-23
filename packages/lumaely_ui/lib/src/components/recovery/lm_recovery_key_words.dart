import 'package:lumaely_ui/src/components/tile/lm_tile.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// the words of a recovery key, numbered, to write down
/// - two columns (1 to 12, then 13 to 24), one with large text
/// - screen readers reads "Word 1, orbit", one word at a time
class LmRecoveryKeyWords extends StatelessWidget {
  const new(this.words, {super.key});

  final List<String> words;

  static const oneColumnTextScale = 1.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scaler = MediaQuery.textScalerOf(context);
    final oneColumn = scaler.scale(10) / 10 >= oneColumnTextScale;
    final numberStyle = LmTypography.labelMedium.copyWith(
      color: colors.textSecondary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final wordStyle = LmTypography.labelLarge.copyWith(
      color: colors.textPrimary,
    );

    Widget line(int index) => Semantics(
      label: 'Word ${index + 1}, ${words[index]}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: LmSpace.s2,
        children: [
          SizedBox(
            width: scaler.scale(20),
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.end,
              style: numberStyle,
            ),
          ),
          Expanded(child: Text(words[index], style: wordStyle)),
        ],
      ),
    );

    Widget column(Iterable<int> indexes) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: LmSpace.s2,
      children: [for (final index in indexes) line(index)],
    );

    final half = (words.length / 2).ceil();

    return LmTile(
      child: Padding(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: oneColumn
            ? column(Iterable.generate(words.length))
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: LmSpace.s4,
                children: [
                  Expanded(child: column(Iterable.generate(half))),
                  Expanded(
                    child: column(
                      Iterable.generate(words.length - half, (i) => half + i),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
