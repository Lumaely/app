import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Playground', type: LmTopBar, path: '[Components]')
Widget topBarPlayground(BuildContext context) {
  final title = context.knobs.string(label: 'Title', initialValue: 'Today');
  final hasAction = context.knobs.boolean(label: 'Action');

  return Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: LmSpace.s5),
        child: LmTopBar(
          title: title,
          onBack: () {},
          action: hasAction
              ? LmIconButton(
                  icon: LmIcons.more,
                  label: 'More',
                  onPressed: () {},
                )
              : null,
        ),
      ),
    ),
  );
}
