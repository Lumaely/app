import 'package:lumaely_ui/src/components/brand/mood_rings_painter.dart';
import 'package:lumaely_ui/src/icons/svg_path.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Lumaely's logo
/// - decorative unless [semanticLabel]: next to the name, screen readers
///   would read "Lumaely" twice
class LmLogo extends StatelessWidget {
  const new({this.size = 64, this.semanticLabel, super.key});

  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final drawing = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: MoodRingsPainter(
          box: 64,
          rings: _rings,
          mark: _brush,
          colors: context.colors,
        ),
      ),
    );

    final label = semanticLabel;

    if (label == null) {
      return ExcludeSemantics(child: drawing);
    }

    return Semantics(label: label, image: true, child: drawing);
  }
}

// logo svg parsed once

final Path _brush = svgPath(
  'M9.6 5.12C7.04 19.2 6.4 38.4 7.04 49.92C7.68 56.32 10.24 58.88 16.64 '
  '58.88C32 59.52 48.64 57.6 59.52 50.56C48.64 55.04 32 55.04 17.92 54.4C14.08 '
  '54.4 12.16 52.48 12.16 48.64C12.16 37.12 11.52 19.2 11.52 5.76C10.88 4.48 '
  '10.24 4.26667 9.6 5.12Z',
);

const _ring1 =
    'M15.36 51.2V16.64C24.5259 16.64 33.3164 20.2811 39.7976 26.7624C46.2789 '
    '33.2436 49.92 42.0341 49.92 51.2H15.36Z';

const _ring2 =
    'M15.36 51.2V23.04C22.8285 23.04 29.9911 26.0069 35.2721 31.2879C40.5532 '
    '36.5689 43.52 43.7315 43.52 51.2H15.36Z';

const _ring3 =
    'M15.36 51.2V29.44C21.1311 29.44 26.6659 31.7326 30.7466 35.8134C34.8274 '
    '39.8941 37.12 45.4289 37.12 51.2H15.36Z';

const _ring4 =
    'M15.36 51.2V35.84C19.4337 35.84 23.3406 37.4583 26.2212 40.3388C29.1017 '
    '43.2194 30.72 47.1263 30.72 51.2H15.36Z';

const _ring5 =
    'M15.36 51.2V42.88C17.5666 42.88 19.6828 43.7566 21.2431 45.3169C22.8034 '
    '46.8772 23.68 48.9934 23.68 51.2H15.36Z';

final List<Path> _rings = [
  _ring1,
  _ring2,
  _ring3,
  _ring4,
  _ring5,
].map(svgPath).toList();
