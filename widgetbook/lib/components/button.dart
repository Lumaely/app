import 'package:flutter/material.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Playground', type: LmButton, path: '[Components]')
Widget buttonPlayground(BuildContext context) {
  final knobs = context.knobs;
  final enabled = knobs.boolean(label: 'Enabled', initialValue: true);
  final icon = knobs.boolean(label: 'Leading icon');

  return Scaffold(
    body: Center(
      child: LmButton(
        label: knobs.string(label: 'Label', initialValue: 'Continue'),
        variant: knobs.object.dropdown(
          label: 'Variant',
          options: LmButtonVariant.values,
          labelBuilder: (variant) => variant.name,
        ),
        large: knobs.boolean(label: 'Large'),
        loading: knobs.boolean(label: 'Loading'),
        leading: icon ? const Icon(Icons.delete_outline) : null,
        onPressed: enabled ? () {} : null,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'All variants', type: LmButton, path: '[Components]')
Widget allButtons(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: LmSpace.s4,
        children: [
          for (final variant in LmButtonVariant.values)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: LmSpace.s4,
              children: [
                LmButton(
                  label: variant.name,
                  variant: variant,
                  onPressed: () {},
                ),
                LmButton(
                  label: variant.name,
                  variant: variant,
                  onPressed: null,
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
