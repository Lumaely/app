import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/mood/mood_marks.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_colors.dart';
import 'package:material_ui/material_ui.dart';

/// big round mood lol
/// - [score] null -> dashed circle, like an empty knob
/// - decorative for screen readers
class LmMoodOrb extends StatelessWidget {
  const new({required this.score, super.key});

  final MoodScore? score;

  static const size = 140.0;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _OrbPainter(score, context.colors)),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  new(this.score, this.colors);

  final MoodScore? score;
  final LmColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    paintKnob(
      canvas,
      size.center(Offset.zero),
      score,
      colors,
      // the outline is drawn half outside
      size: size.shortestSide - lineWidth,
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) {
    return old.score != score || old.colors != colors;
  }
}
