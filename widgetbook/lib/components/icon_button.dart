import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// as in a top bar: back on the left, more on the right
@widgetbook.UseCase(name: 'Top bar', type: LmIconButton, path: '[Components]')
Widget iconButtons(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);

  return Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: LmSpace.s5),
        child: Row(
          children: [
            LmIconButton(
              icon: LmIcons.chevronLeft,
              label: 'Back',
              onPressed: enabled ? () {} : null,
            ),
            const Spacer(),
            LmIconButton(
              icon: LmIcons.more,
              label: 'More',
              onPressed: enabled ? () {} : null,
            ),
          ],
        ),
      ),
    ),
  );
}

// next to the main button of a page
@widgetbook.UseCase(name: 'Outlined', type: LmIconButton, path: '[Components]')
Widget outlinedIconButton(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);

  return Scaffold(
    body: Center(
      child: LmIconButton(
        icon: LmIcons.chevronUpDown,
        label: 'Switch mode',
        outlined: true,
        onPressed: enabled ? () {} : null,
      ),
    ),
  );
}
