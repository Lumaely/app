import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Logo', type: LmLogo, path: '[Components]')
Widget logo(BuildContext context) {
  final size = context.knobs.double.slider(
    label: 'Size',
    initialValue: 64,
    min: 24,
    max: 256,
  );

  return Scaffold(
    body: Center(child: LmLogo(size: size)),
  );
}

// as on the welcome screen: from the bottom left corner
@widgetbook.UseCase(name: 'Cover rise', type: LmCoverRise, path: '[Components]')
Widget coverRise(BuildContext context) {
  final size = context.knobs.double.slider(
    label: 'Size',
    initialValue: 360,
    min: 72,
    max: 600,
  );

  return Scaffold(
    body: Stack(
      children: [
        Positioned(left: 0, bottom: 0, child: LmCoverRise(size: size)),
      ],
    ),
  );
}
