import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// as on the start screen
@widgetbook.UseCase(
  name: 'Start choices',
  type: LmChoiceTile,
  path: '[Components]',
)
Widget choiceTiles(BuildContext context) {
  final knobs = context.knobs;

  return Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: Column(
          spacing: LmSpace.s4,
          children: [
            LmChoiceTile(
              icon: LmIcons.sparkles,
              title: knobs.string(label: 'Title', initialValue: 'I’m new'),
              description: knobs.string(
                label: 'Description',
                initialValue: 'Start a new diary.',
              ),
              onTap: () {},
            ),
            LmChoiceTile(
              icon: LmIcons.signIn,
              title: 'I have a diary',
              description: 'Sign in or connect your server.',
              onTap: () {},
            ),
          ],
        ),
      ),
    ),
  );
}
