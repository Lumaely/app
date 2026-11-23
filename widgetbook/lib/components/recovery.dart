import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// sample words, not a real key
const _words = [
  'orbit',
  'velvet',
  'harbor',
  'kitten',
  'meadow',
  'silver',
  'canyon',
  'lemon',
  'pilot',
  'quiet',
  'ribbon',
  'stone',
  'tunnel',
  'violin',
  'walnut',
  'yellow',
  'anchor',
  'breeze',
  'copper',
  'domain',
  'ember',
  'frost',
  'galaxy',
  'island',
];

@widgetbook.UseCase(
  name: 'Recovery key',
  type: LmRecoveryKeyWords,
  path: '[Components]',
)
Widget recoveryKeyWords(BuildContext context) {
  return const Scaffold(
    body: SingleChildScrollView(
      padding: EdgeInsets.all(LmSpace.s5),
      child: LmRecoveryKeyWords(_words),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Playground',
  type: LmCheckboxRow,
  path: '[Components]',
)
Widget checkboxRow(BuildContext context) {
  final error = context.knobs.boolean(label: 'Error');

  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(LmSpace.s5),
      child: _CheckboxDemo(error: error),
    ),
  );
}

class _CheckboxDemo extends StatefulWidget {
  const new({required this.error});

  final bool error;

  @override
  State<_CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<_CheckboxDemo> {
  var _value = false;

  @override
  Widget build(BuildContext context) {
    return LmCheckboxRow(
      label: 'I saved my recovery key somewhere safe',
      value: _value,
      onChanged: (value) => setState(() => _value = value),
      error: widget.error ? 'Check the box once your key is saved.' : null,
    );
  }
}
