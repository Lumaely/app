import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Playground', type: LmIconBadge, path: '[Components]')
Widget iconBadgePlayground(BuildContext context) {
  return Scaffold(
    body: Center(
      child: LmIconBadge(
        context.knobs.object.dropdown(
          label: 'Icon',
          options: LmIcons.values,
          initialOption: LmIcons.check,
          labelBuilder: (icon) => icon.name,
        ),
      ),
    ),
  );
}
