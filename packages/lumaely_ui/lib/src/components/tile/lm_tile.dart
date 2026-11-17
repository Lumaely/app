import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:material_ui/material_ui.dart';

/// rounded card on the screen background
/// - `surface` fill, radius `tile`
/// - [color]: other fill, e.g. `colors.background` in a sheet or dialog
///   (surface raised): a white tile on a white sheet can't be seen in dawn
/// - any child (rows, a chart, a calendar...)
/// - it's a Material: ink of the rows inside is drawn on it and clipped to
///   the rounded shape
class LmTile extends StatelessWidget {
  const new({required this.child, this.color, super.key});

  final Widget child;

  /// null -> `surface`
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(LmRadius.tile)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
