import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// short text in a rounded box on the screen background, e.g. the streak
/// - only shows something, can't be tapped
/// - [semanticLabel]: read instead of the text by screen readers, when it's
///   too short to be clear ("12 days" -> "12 days in a row")
class LmPill extends StatelessWidget {
  const new(this.text, {this.semanticLabel, super.key});

  final String text;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: LmSpace.s3, vertical: 6),
      decoration: ShapeDecoration(
        color: colors.surface,
        shape: const StadiumBorder(),
      ),
      child: Text(
        text,
        semanticsLabel: semanticLabel,
        style: LmTypography.labelLarge.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
