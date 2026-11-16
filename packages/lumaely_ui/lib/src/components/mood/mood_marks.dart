import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/mood/lm_mood_labels.dart';
import 'package:lumaely_ui/src/tokens/lm_colors.dart';

// drawing shared by the mood curve and the mood slider (not exported)
// sizes come from figma (Entry · Mood)

const double knobSize = 26;
const double railWidth = 6;
const double lineWidth = 2.5;
const double _notchSize = 6;

/// rail from [start] to [end], with the 5 notches
void paintRail(Canvas canvas, Offset start, Offset end, LmColors colors) {
  final rail = Paint()
    ..color = colors.border
    ..strokeWidth = railWidth
    ..strokeCap = StrokeCap.round;

  final notch = Paint()..color = colors.borderStrong;

  canvas.drawLine(start, end, rail);

  for (var i = 0; i < 5; i++) {
    canvas.drawCircle(Offset.lerp(start, end, i / 4)!, _notchSize / 2, notch);
  }
}

/// knob in the mood color with a dark outline
/// [score] null -> empty: dashed circle
void paintKnob(Canvas canvas, Offset center, MoodScore? score, LmColors c) {
  const radius = knobSize / 2;

  if (score == null) {
    canvas.drawCircle(center, radius, Paint()..color = c.surface);
    _dashedCircle(
      canvas,
      center,
      radius - 1,
      Paint()
        ..color = c.borderStrong
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    return;
  }

  canvas
    ..drawCircle(center, radius, Paint()..color = c.mood(score))
    ..drawCircle(
      center,
      radius,
      Paint()
        ..color = c.textPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth,
    );
}

// dashes of 4, gaps of 3
void _dashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
  const dash = 4.0;
  const gap = 3.0;
  final count = (2 * math.pi * radius / (dash + gap)).floor();
  final step = 2 * math.pi / count;
  final sweep = step * dash / (dash + gap);
  final rect = Rect.fromCircle(center: center, radius: radius);

  for (var i = 0; i < count; i++) {
    canvas.drawArc(rect, i * step, sweep, false, paint);
  }
}
