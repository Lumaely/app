import 'dart:ui' show Path;

import 'package:path_parsing/path_parsing.dart';

/// a flutter Path from svg path data (the `d` attribute of a `<path>`)
Path svgPath(String data) {
  final path = Path();
  writeSvgPathDataToPath(data, _PathProxy(path));
  return path;
}

class _PathProxy implements PathProxy {
  new(this.path);

  final Path path;

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}
