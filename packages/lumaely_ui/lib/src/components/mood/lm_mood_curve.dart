import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/mood/lm_mood_labels.dart';
import 'package:lumaely_ui/src/components/mood/mood_marks.dart';
import 'package:lumaely_ui/src/components/mood/mood_target.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_colors.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';

/// the moods of a day, moment by moment
/// - one column per moment, Rough at the bottom, Great at the top
/// - [moments]: the columns, in the order of the day (2 to 5)
/// - [scores]: filled moments only, the others are empty (dashed circle)
/// - the line only joins two filled moments next to each other
class LmMoodCurve extends StatelessWidget {
  const new({
    required this.moments,
    required this.scores,
    required this.onChanged,
    super.key,
  });

  final List<Moment> moments;
  final Map<Moment, MoodScore> scores;
  final void Function(Moment moment, MoodScore score) onChanged;

  static const double _height = 250;
  static const double _axisWidth = 40;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final small = LmTypography.labelSmall.copyWith(color: colors.textSecondary);
    // room for 2 lines of moment names, even with a big text size
    final namesHeight =
        MediaQuery.textScalerOf(context).scale(small.fontSize!) *
        small.height! *
        2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: LmSpace.s2,
      children: [
        // the moods are read by each column, no need to read this
        ExcludeSemantics(
          child: SizedBox(
            width: _axisWidth,
            height: _height,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: LmSpace.s3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(moodLabel(MoodScore.great), style: small),
                  Text(moodLabel(MoodScore.rough), style: small),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = _CurveLayout(constraints.maxWidth, moments.length);
              // the whole column reacts, at least 48 wide
              final target = math.min(layout.step, 64).toDouble();
              final name = math.min(layout.step, 88).toDouble();

              return SizedBox(
                height: _height + LmSpace.s2 + namesHeight,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: _height,
                      child: CustomPaint(
                        painter: _CurvePainter(layout, [
                          for (final moment in moments) scores[moment],
                        ], colors),
                      ),
                    ),
                    for (final (i, moment) in moments.indexed) ...[
                      Positioned(
                        left: layout.x(i) - target / 2,
                        width: target,
                        top: 0,
                        height: _height,
                        child: MoodTarget(
                          label: momentLabel(moment),
                          score: scores[moment],
                          onChanged: (score) => onChanged(moment, score),
                          scoreAt: (position) => layout.scoreAt(position.dy),
                          axis: Axis.vertical,
                        ),
                      ),
                      Positioned(
                        // centered under the column, but kept inside
                        left: (layout.x(i) - name / 2)
                            .clamp(0, constraints.maxWidth - name)
                            .toDouble(),
                        width: name,
                        top: _height + LmSpace.s2,
                        child: ExcludeSemantics(
                          child: Text(
                            momentLabel(moment),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: small.copyWith(
                              color: scores[moment] == null
                                  ? colors.textSecondary
                                  : colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// where things are in the chart (sizes from figma)
class _CurveLayout {
  new(this.width, this.count);

  final double width;
  final int count;

  static const double top = 20;
  static const double bottom = 230;
  static const double inset = 22;

  double get step =>
      count > 1 ? (width - 2 * inset) / (count - 1) : width - 2 * inset;

  double x(int index) => count > 1 ? inset + index * step : width / 2;

  double y(MoodScore score) => bottom - (score.value - 1) * (bottom - top) / 4;

  MoodScore scoreAt(double dy) {
    final level = ((bottom - dy) / ((bottom - top) / 4)).round() + 1;
    return MoodScore.fromValue(level.clamp(1, 5));
  }
}

class _CurvePainter extends CustomPainter {
  new(this.layout, this.scores, this.colors);

  final _CurveLayout layout;
  final List<MoodScore?> scores;
  final LmColors colors;

  // empty moments sit in the middle
  Offset _knob(int i) {
    return Offset(layout.x(i), layout.y(scores[i] ?? MoodScore.okay));
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < scores.length; i++) {
      paintRail(
        canvas,
        Offset(layout.x(i), _CurveLayout.top),
        Offset(layout.x(i), _CurveLayout.bottom),
        colors,
      );
    }

    final line = Paint()
      ..color = colors.textPrimary
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < scores.length - 1; i++) {
      if (scores[i] != null && scores[i + 1] != null) {
        canvas.drawLine(_knob(i), _knob(i + 1), line);
      }
    }

    for (var i = 0; i < scores.length; i++) {
      paintKnob(canvas, _knob(i), scores[i], colors);
    }
  }

  @override
  bool shouldRepaint(_CurvePainter old) {
    return old.layout.width != layout.width ||
        old.layout.count != layout.count ||
        old.colors != colors ||
        !listEquals(old.scores, scores);
  }
}
