import 'package:flutter/painting.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/tokens/lm_colors.dart';

// FIXME: english for now, translations later

String moodLabel(MoodScore score) => switch (score) {
  MoodScore.rough => 'Rough',
  MoodScore.low => 'Low',
  MoodScore.okay => 'Okay',
  MoodScore.good => 'Good',
  MoodScore.great => 'Great',
};

String momentLabel(Moment moment) => switch (moment) {
  Moment.morning => 'Morning',
  Moment.noon => 'Noon',
  Moment.afternoon => 'Afternoon',
  Moment.evening => 'Evening',
  Moment.night => 'Night',
};

/// average as shown in the ui: one decimal (3.67 -> 3.7)
double shownAverage(double average) => (average * 10).round() / 10;

/// mood word of an average, half up (3.5 -> Good)
/// - from the shown value, so text and word always agree
MoodScore moodOfAverage(double average) {
  return MoodScore.fromValue(shownAverage(average).round());
}

/// "4/5 · Good" (whole day) or "3.5/5 · Good · 4 moments"
String moodLine(DayMoods moods) {
  final average = moods.average;
  final line =
      '${averageText(average)}/5 · ${moodLabel(moodOfAverage(average))}';

  return switch (moods) {
    WholeDayMood() => line,
    MomentMoods(:final scores) => '$line · ${_momentCount(scores.length)}',
  };
}

/// same as [moodLine], for screen readers: "Good, 3.5 of 5. 4 moments"
String moodSemantics(DayMoods moods) {
  final average = moods.average;
  final text =
      '${moodLabel(moodOfAverage(average))}, '
      '${averageText(average)} of 5';

  return switch (moods) {
    WholeDayMood() => text,
    MomentMoods(:final scores) => '$text. ${_momentCount(scores.length)}',
  };
}

/// 4.0 -> "4", 3.5 -> "3.5"
String averageText(double average) {
  final shown = shownAverage(average);
  if (shown == shown.roundToDouble()) {
    return shown.toInt().toString();
  }
  return shown.toStringAsFixed(1);
}

String _momentCount(int count) => count == 1 ? '1 moment' : '$count moments';

extension LmMoodColors on LmColors {
  /// fill of a mood mark (knob, dot, pixel...)
  /// never alone: always with a position, a label or an outline (not only
  /// color, some moods are too light on the background)
  Color mood(MoodScore score) => switch (score) {
    MoodScore.rough => mood1,
    MoodScore.low => mood2,
    MoodScore.okay => mood3,
    MoodScore.good => mood4,
    MoodScore.great => mood5,
  };

  /// fill for an average: between the two moods around it
  /// (3.2 -> 20 % of the way from okay to good)
  /// - plain Color.lerp: no visible difference with OKLab here
  Color moodAverage(double average) {
    final shown = shownAverage(average);
    final low = MoodScore.fromValue(shown.floor());
    final high = MoodScore.fromValue(shown.ceil());

    return Color.lerp(mood(low), mood(high), shown - low.value)!;
  }

  /// outline for moods too close to the tile color, null for the others
  /// - rough: almost invisible on firefly (mood1Outline, = mood1 on dawn)
  /// - great: light yellow on dawn's white (as in figma)
  Color? moodOutline(MoodScore score) => switch (score) {
    MoodScore.rough => mood1Outline,
    MoodScore.great => border,
    _ => null,
  };
}
