import 'package:flutter/material.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';

/// rounded card on the screen background
/// - `surface` fill, radius `tile`
/// - any child (rows, a chart, a calendar...)
/// - it's a Material: ink of the rows inside is drawn on it and clipped to
///   the rounded shape
class LmTile extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(LmRadius.tile)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
