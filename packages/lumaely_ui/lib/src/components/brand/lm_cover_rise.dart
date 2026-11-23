import 'package:lumaely_ui/src/components/brand/mood_rings_painter.dart';
import 'package:lumaely_ui/src/icons/svg_path.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:material_ui/material_ui.dart';

/// the five moods rising from a corner
class LmCoverRise extends StatelessWidget {
  const new({this.size = 360, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: MoodRingsPainter(
            box: 360,
            rings: _rings,
            colors: context.colors,
          ),
        ),
      ),
    );
  }
}

// svg paths

const _ring1 =
    'M0 360V0C95.4779 0 187.045 37.9285 254.558 105.442C322.072 172.955 360 '
    '264.522 360 360H0Z';

const _ring2 =
    'M0 360V72C76.3823 72 149.636 102.343 203.647 156.353C257.657 210.364 288 '
    '283.618 288 360H0Z';

const _ring3 =
    'M0 360V144C57.2868 144 112.227 166.757 152.735 207.265C193.243 247.773 '
    '216 302.713 216 360H0Z';

const _ring4 =
    'M0 360V216C38.1912 216 74.8181 231.171 101.823 258.177C128.829 285.182 '
    '144 321.809 144 360H0Z';

const _ring5 =
    'M0 360V288C19.0956 288 37.4091 295.586 50.9117 309.088C64.4143 322.591 72 '
    '340.904 72 360H0Z';

final List<Path> _rings = [
  _ring1,
  _ring2,
  _ring3,
  _ring4,
  _ring5,
].map(svgPath).toList();
