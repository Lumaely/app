import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// a small mark (dot, icon) of [size] before a text in [style], its middle on
/// the middle of the text's lowercase letters, on the first line
/// - the line box is taller than the letters: centring on it looks too high
/// - follows the text size
/// - goes first in a Row with CrossAxisAlignment.start, the text after it
class LmLineMark extends StatelessWidget {
  const new({
    required this.style,
    required this.size,
    required this.child,
    super.key,
  });

  final TextStyle style;
  final double size;
  final Widget child;

  /// height of the lowercase letters of Plus Jakarta Sans, per font size
  /// (sxHeight (536) / unitsPerEm (1000) in the font file)
  static const xHeight = 0.536;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final painter = TextPainter(
      text: TextSpan(text: 'x', style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();

    final baseline = painter.computeLineMetrics().first.baseline;

    painter.dispose();

    final middle = baseline - scaler.scale(style.fontSize!) * xHeight / 2;

    return Padding(
      padding: EdgeInsets.only(top: math.max(0, middle - size / 2)),
      child: SizedBox.square(dimension: size, child: child),
    );
  }
}
