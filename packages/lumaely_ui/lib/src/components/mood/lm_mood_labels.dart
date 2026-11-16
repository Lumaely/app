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
}
