import 'package:flutter/material.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Playground', type: LmMoodCurve, path: '[Components]')
Widget moodCurvePlayground(BuildContext context) {
  final count = context.knobs.int.slider(
    label: 'Moments',
    initialValue: 4,
    min: 2,
    max: 5,
  );
  // same sets as the figma section "Moments · 2 to 5"
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
        child: _CurveDemo(moments: moments),
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
  return const Scaffold(
    body: Center(
      child: Padding(padding: EdgeInsets.all(LmSpace.s5), child: _SliderDemo()),
    ),
  );
}

// keeps the scores so the widgets can be played with
class _CurveDemo extends StatefulWidget {
  const new({required this.moments, super.key});

  final List<Moment> moments;

  @override
  State<_CurveDemo> createState() => _CurveDemoState();
}

class _CurveDemoState extends State<_CurveDemo> {
  var _scores = <Moment, MoodScore>{};

  @override
  Widget build(BuildContext context) {
    return LmMoodCurve(
      moments: widget.moments,
      scores: _scores,
      onChanged: (moment, score) {
        setState(() => _scores = {..._scores, moment: score});
      },
    );
  }
}

class _SliderDemo extends StatefulWidget {
  const new();

  @override
  State<_SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<_SliderDemo> {
  MoodScore? _score;

  @override
  Widget build(BuildContext context) {
    return LmMoodSlider(
      score: _score,
      onChanged: (score) => setState(() => _score = score),
    );
  }
}
