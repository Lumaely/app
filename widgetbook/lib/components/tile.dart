import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// settings-like rows for the group use cases
const List<(LmIcons, String, String?)> _rows = [
  (LmIcons.appearance, 'Appearance', 'Automatic'),
  (LmIcons.bell, 'Reminders', '21:00'),
  (LmIcons.lock, 'Privacy', null),
  (LmIcons.storage, 'Storage', 'This device'),
  (LmIcons.help, 'Help', null),
];

Widget _screen(Widget child) {
  return Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: child,
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Playground', type: LmTile, path: '[Components]')
Widget tilePlayground(BuildContext context) {
  return _screen(
    const LmTile(
      child: Padding(
        padding: EdgeInsets.all(LmSpace.s4),
        child: Text('Any content: a chart, a calendar...'),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Playground', type: LmTileGroup, path: '[Components]')
Widget tileGroupPlayground(BuildContext context) {
  final knobs = context.knobs;
  final count = knobs.int.slider(
    label: 'Rows',
    initialValue: 3,
    min: 1,
    max: _rows.length,
  );
  final title = knobs.boolean(label: 'Title', initialValue: true);
  final titleVariant = knobs.object.dropdown(
    label: 'Title variant',
    options: LmTileGroupTitleVariant.values,
    labelBuilder: (variant) => variant.name,
  );

  return _screen(
    LmTileGroup(
      title: title ? 'Settings' : null,
      titleVariant: titleVariant,
      children: [
        for (final (icon, label, value) in _rows.take(count))
          LmTileRow(
            leading: LmTileIcon(icon),
            title: label,
            value: value,
            onTap: () {},
          ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Playground', type: LmTileRow, path: '[Components]')
Widget tileRowPlayground(BuildContext context) {
  final knobs = context.knobs;
  final subtitle = knobs.boolean(label: 'Subtitle');
  final value = knobs.boolean(label: 'Value', initialValue: true);
  final leading = knobs.boolean(label: 'Leading', initialValue: true);
  final tappable = knobs.boolean(label: 'Tappable', initialValue: true);

  return _screen(
    LmTile(
      child: LmTileRow(
        title: knobs.string(label: 'Title', initialValue: 'Appearance'),
        subtitle: subtitle ? 'Dawn by day, Firefly at night' : null,
        value: value ? 'Automatic' : null,
        leading: leading ? const LmTileIcon(LmIcons.appearance) : null,
        onTap: tappable ? () {} : null,
      ),
    ),
  );
}
