import 'package:flutter/widgets.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/icons/svg_path.dart';

/// draws an icon of [LmIcons]
/// - like Icon: size and color come from the IconTheme when not given (so it
///   works in buttons and IconButton without passing anything)
/// - [semanticLabel] null -> decorative, screen readers skip it
///
/// why not the phosphor font: on apple (CoreText) some glyphs came out with
/// thinner lines in places. drawing the svg path gives the same result
/// everywhere
class LmIcon extends StatelessWidget {
  const new(this.icon, {this.size, this.color, this.semanticLabel, super.key});

  final LmIcons icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = this.size ?? theme.size ?? 24;
    final color = this.color ?? theme.color ?? const Color(0xFF000000);

    final drawing = SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _IconPainter(_pathOf(icon), color)),
    );
    final label = semanticLabel;
    if (label == null) {
      return ExcludeSemantics(child: drawing);
    }
    return Semantics(label: label, image: true, child: drawing);
  }
}

// parsed once per icon
final _paths = <LmIcons, Path>{};

Path _pathOf(LmIcons icon) => _paths[icon] ??= svgPath(icon.path);

class _IconPainter extends CustomPainter {
  new(this.path, this.color);

  final Path path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // svg paths are in a 256 x 256 box
    canvas
      ..save()
      ..scale(size.width / 256)
      ..drawPath(path, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(_IconPainter old) {
    return old.path != path || old.color != color;
  }
}
