import 'package:lumaely_ui/src/tokens/lm_colors.dart';
import 'package:material_ui/material_ui.dart';

/// quarter discs in the five mood colors, rough (outside) to great (inside),
/// as in the logo and the welcome cover (not exported)
/// - [rings]: svg paths, outside first, in a [box] x [box] frame
/// - the outside ring gets a 1 px mood1Outline line inside its edge: on
///   firefly, mood 1 is close to the background
/// - [mark]: an extra path on top, in textPrimary (the logo's L)
class MoodRingsPainter extends CustomPainter {
  new({
    required this.box,
    required this.rings,
    required this.colors,
    this.mark,
  });

  final double box;
  final List<Path> rings;
  final LmColors colors;
  final Path? mark;

  @override
  void paint(Canvas canvas, Size size) {
    final fills = [
      colors.mood1,
      colors.mood2,
      colors.mood3,
      colors.mood4,
      colors.mood5,
    ];

    canvas
      ..save()
      ..scale(size.width / box);

    for (final (index, ring) in rings.indexed) {
      canvas.drawPath(ring, Paint()..color = fills[index]);
    }

    // outline inside the outside ring only (clip = the ring itself)
    canvas
      ..save()
      ..clipPath(rings.first)
      ..drawPath(
        rings.first,
        Paint()
          ..color = colors.mood1Outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * box / size.width,
      )
      ..restore();

    if (mark case final mark?) {
      canvas.drawPath(mark, Paint()..color = colors.textPrimary);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(MoodRingsPainter old) {
    return old.box != box ||
        old.rings != rings ||
        old.colors != colors ||
        old.mark != mark;
  }
}
