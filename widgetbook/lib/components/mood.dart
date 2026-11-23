import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

final _curveScores = ValueNotifier<Map<Moment, MoodScore>>({});
final _sliderScore = ValueNotifier<MoodScore?>(null);

@widgetbook.UseCase(name: 'Playground', type: LmMoodCurve, path: '[Components]')
Widget moodCurvePlayground(BuildContext context) {
  final count = context.knobs.int.slider(
    label: 'Moments',
    initialValue: 4,
    min: 2,
    max: 5,
  );
  // the moment sets, from 2 to 5 moments
  final moments = switch (count) {
    2 => const [Moment.afternoon, Moment.evening],
    3 => const [Moment.morning, Moment.afternoon, Moment.evening],
    4 => const [Moment.morning, Moment.noon, Moment.afternoon, Moment.evening],
    _ => Moment.values,
  };

  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: ValueListenableBuilder(
          valueListenable: _curveScores,
          builder: (context, scores, _) => LmMoodCurve(
            moments: moments,
            scores: scores,
            onChanged: (moment, score) {
              _curveScores.value = {...scores, moment: score};
            },
          ),
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Playground',
  type: LmMoodSlider,
  path: '[Components]',
)
Widget moodSliderPlayground(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: ValueListenableBuilder(
          valueListenable: _sliderScore,
          builder: (context, score, _) => LmMoodSlider(
            score: score,
            onChanged: (score) => _sliderScore.value = score,
          ),
        ),
      ),
    ),
  );
}
