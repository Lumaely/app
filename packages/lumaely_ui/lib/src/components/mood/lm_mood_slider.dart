import 'package:flutter/material.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/mood/lm_mood_labels.dart';
import 'package:lumaely_ui/src/components/mood/mood_marks.dart';
import 'package:lumaely_ui/src/components/mood/mood_target.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_colors.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';

/// one mood for the whole day: a rail with its 5 steps numbered, Rough to
/// Great (1-5)
/// - [score] null -> empty knob in the middle
/// - [label] is what screen readers say before the value
class LmMoodSlider extends StatelessWidget {
  const new({
    required this.score,
    required this.onChanged,
    this.label = 'Mood for this day',
    super.key,
  });

  final MoodScore? score;
  final ValueChanged<MoodScore> onChanged;
  final String label;

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final small = LmTypography.labelSmall.copyWith(color: colors.textSecondary);
    final numbersHeight =
        MediaQuery.textScalerOf(context).scale(small.fontSize!) * small.height!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _SliderLayout(constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: LmSpace.s1,
          children: [
            SizedBox(
              height: _height,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SliderPainter(layout, score, colors),
                    ),
                  ),
                  Positioned.fill(
                    child: MoodTarget(
                      label: label,
                      score: score,
                      onChanged: onChanged,
                      scoreAt: (position) => layout.scoreAt(position.dx),
                      axis: Axis.horizontal,
                    ),
                  ),
                ],
              ),
            ),
            // 1 to 5 under the notches, the current one darker
            ExcludeSemantics(
              child: SizedBox(
                height: numbersHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final step in MoodScore.values)
                      Positioned(
                        left: layout.x(step) - 12,
                        width: 24,
                        top: 0,
                        child: Text(
                          '${step.value}',
                          textAlign: TextAlign.center,
                          style: step == score
                              ? small.copyWith(color: colors.textPrimary)
                              : small,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(moodLabel(MoodScore.rough), style: small),
                  Text(moodLabel(MoodScore.great), style: small),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// where the steps are (the knob never goes past the ends)
class _SliderLayout {
  new(this.width);

  final double width;

  static const double inset = knobSize / 2;
  static const double centerY = LmMoodSlider._height / 2;

  double get _step => (width - 2 * inset) / 4;

  double x(MoodScore score) => inset + (score.value - 1) * _step;

  MoodScore scoreAt(double dx) {
    final level = ((dx - inset) / _step).round() + 1;
    return MoodScore.fromValue(level.clamp(1, 5));
  }
}

class _SliderPainter extends CustomPainter {
  new(this.layout, this.score, this.colors);

  final _SliderLayout layout;
  final MoodScore? score;
  final LmColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    const y = _SliderLayout.centerY;
    paintRail(
      canvas,
      Offset(layout.x(MoodScore.rough), y),
      Offset(layout.x(MoodScore.great), y),
      colors,
    );
    paintKnob(
      canvas,
      Offset(layout.x(score ?? MoodScore.okay), y),
      score,
      colors,
    );
  }

  @override
  bool shouldRepaint(_SliderPainter old) {
    return old.layout.width != layout.width ||
        old.score != score ||
        old.colors != colors;
  }
}
