import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// what part of the letters a mark is centred on
enum LmLineMarkAlign {
  /// the lowercase letters: small marks (a dot, an icon)
  lowercase,

  /// the capitals: marks as tall as the text or more (a checkbox), which the
  /// eye compares to the whole word
  capitals,

  /// halfway between both: a title next to a bigger button
  balanced,
}

/// a mark (dot, icon, box) of [size] before a text in [style], centred on the
/// letters of the first line (see [align])
/// - the line box is taller than the letters: centring on it looks too high
/// - follows the text size
/// - goes first in a Row with CrossAxisAlignment.start, the text after it
class LmLineMark extends StatelessWidget {
  const new({
    required this.style,
    required this.size,
    required this.child,
    this.align = LmLineMarkAlign.lowercase,
    super.key,
  });

  final TextStyle style;
  final double size;
  final Widget child;
  final LmLineMarkAlign align;

  /// height of the lowercase letters of Plus Jakarta Sans, per font size
  /// (sxHeight (536) / unitsPerEm (1000) in the font file)
  static const xHeight = 0.536;

  /// height of its capitals (sCapHeight 745 / unitsPerEm 1000)
  static const capHeight = 0.745;

  /// middle of the letters of a line in [style], from the top of the line
  static double lettersMiddle(
    TextStyle style, {
    required TextScaler scaler,
    LmLineMarkAlign align = LmLineMarkAlign.lowercase,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: 'x', style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();

    final baseline = painter.computeLineMetrics().first.baseline;

    painter.dispose();

    final letters = switch (align) {
      LmLineMarkAlign.lowercase => xHeight,
      LmLineMarkAlign.capitals => capHeight,
      LmLineMarkAlign.balanced => (xHeight + capHeight) / 2,
    };

    return baseline - scaler.scale(style.fontSize!) * letters / 2;
  }

  @override
  Widget build(BuildContext context) {
    final middle = lettersMiddle(
      style,
      scaler: MediaQuery.textScalerOf(context),
      align: align,
    );

    return Padding(
      padding: EdgeInsets.only(top: math.max(0, middle - size / 2)),
      child: SizedBox.square(dimension: size, child: child),
    );
  }
}
