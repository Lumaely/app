import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Playground', type: LmPill, path: '[Components]')
Widget pillPlayground(BuildContext context) {
  return Scaffold(
    body: Center(
      child: LmPill(
        context.knobs.string(label: 'Text', initialValue: '2,401 days'),
      ),
    ),
  );
}
