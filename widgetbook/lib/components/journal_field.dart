import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Playground',
  type: LmJournalField,
  path: '[Components]',
)
Widget journalFieldPlayground(BuildContext context) {
  return Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: LmJournalField(
          readOnly: context.knobs.boolean(label: 'Read only'),
        ),
      ),
    ),
  );
}
