import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Playground',
  type: LmProgressSteps,
  path: '[Components]',
)
Widget progressStepsPlayground(BuildContext context) {
  final count = context.knobs.int.slider(
    label: 'Steps',
    initialValue: 6,
    min: 1,
    max: 6,
  );
  final current = context.knobs.int.slider(
    label: 'Current',
    initialValue: 1,
    min: 1,
    max: 6,
  );

  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: LmProgressSteps(current: current.clamp(1, count), count: count),
      ),
    ),
  );
}
