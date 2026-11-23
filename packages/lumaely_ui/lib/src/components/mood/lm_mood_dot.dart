import 'package:lumaely_ui/src/components/mood/lm_mood_labels.dart';
import 'package:lumaely_ui/src/components/mood/mood_marks.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:material_ui/material_ui.dart';

/// round mood mark of a day (lists, calendars)
/// - [average] from 1 to 5: a score (4.0) or an average (3.5, blended color)
/// - [average] null -> nothing written: dashed circle
/// - decorative for screen readers: the row / cell says the mood in words
class LmMoodDot extends StatelessWidget {
  const new({required this.average, this.size = defaultSize, super.key});

  final double? average;
  final double size;

  /// size in the journal list
  static const defaultSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final average = this.average;

    final painter = average == null
        ? _DotPainter(dash: colors.borderStrong)
        : _DotPainter(
            fill: colors.moodAverage(average),
            outline: colors.moodOutline(moodOfAverage(average)),
          );

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: painter),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  new({this.fill, this.outline, this.dash});

  final Color? fill;
  final Color? outline;
  final Color? dash;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final fill = this.fill;
    final outline = this.outline;
    final dash = this.dash;

    if (fill != null) {
      canvas.drawCircle(center, radius, Paint()..color = fill);
    }

    // 1 px, inside the circle (same size with or without outline)
    if (outline != null) {
      canvas.drawCircle(
        center,
        radius - 0.5,
        Paint()
          ..color = outline
          ..style = PaintingStyle.stroke
          // 0 would be a hairline (1 device pixel)
          ..strokeWidth = 1,
      );
    }
    if (dash != null) {
      paintDashedCircle(
        canvas,
        center,
        radius - 1,
        Paint()
          ..color = dash
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_DotPainter old) {
    return old.fill != fill || old.outline != outline || old.dash != dash;
  }
}
