import 'package:intl/intl.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/chart/mood_chart_series.dart';
import 'package:lumaely_ui/src/components/mood/lm_mood_labels.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_colors.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// mood over a period, on a fixed 1 to 5 axis (Insights)
/// - 5 grid lines (1 to 5), labels 5, 3, 1
/// - the line is cut where nothing was written
/// - a dot per point when the dots don't touch (they need
///   MoodChartPainter.minDotGap); otherwise dots only where each line starts
///   and ends
/// - [smoothing]: per day, 7 day rolling average, per week, per month; one
///   that doesn't fit the period (monthly over a week) falls back to
///   LmMoodChartSmoothing.autoFor
/// - screen readers get a summary (average, lowest and highest mood, days
///   written); the title and the tile around are the screen's job
class LmMoodChart extends StatelessWidget {
  const new({
    required this.from,
    required this.to,
    required this.entries,
    this.smoothing = LmMoodChartSmoothing.none,
    super.key,
  });

  /// first and last day of the period, included
  final LocalDate from;
  final LocalDate to;

  /// the entries, by date; days before [from] feed the rolling average
  final Map<LocalDate, DayEntry> entries;

  final LmMoodChartSmoothing smoothing;

  /// [smoothing], or the automatic one if it doesn't fit the period
  LmMoodChartSmoothing get usedSmoothing {
    final days = to.daysSince(from) + 1;
    return LmMoodChartSmoothing.availableFor(days).contains(smoothing)
        ? smoothing
        : LmMoodChartSmoothing.autoFor(days);
  }

  /// height of the grid, from 5 to 1 (figma)
  static const plotHeight = 84.0;

  /// text scale from which the middle date is dropped (no room for 3)
  static const twoDatesTextScale = 1.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelStyle = LmTypography.labelSmall.copyWith(
      color: colors.textSecondary,
    );
    // half a line of label: 5, 3 and 1 are centred on their grid line
    final fontSize = labelStyle.fontSize!;
    final scaled = MediaQuery.textScalerOf(context).scale(fontSize);
    final pad = scaled * labelStyle.height! / 2;
    final twoDates = scaled / fontSize >= twoDatesTextScale;
    final smoothing = usedSmoothing;
    final lines = moodChartLines(
      from: from,
      to: to,
      moods: {
        for (final entry in entries.values) entry.date: entry.moods.average,
      },
      smoothing: smoothing,
    );
    final span = to.daysSince(from);
    final dateFormat = DateFormat(span > 180 ? 'MMM y' : 'MMM d');
    String date(LocalDate day) =>
        dateFormat.format(DateTime(day.year, day.month, day.day));

    final chart = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: LmSpace.s2,
      children: [
        SizedBox(
          height: plotHeight + 2 * pad,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final value in ['5', '3', '1'])
                Text(value, style: labelStyle),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: LmSpace.s1,
            children: [
              SizedBox(
                height: plotHeight + 2 * pad,
                child: CustomPaint(
                  painter: MoodChartPainter(
                    lines: lines,
                    span: span,
                    pad: pad,
                    colors: colors,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: LmSpace.s2,
                children: [
                  // flexible: a date wraps rather than overflow (big text)
                  Flexible(child: Text(date(from), style: labelStyle)),
                  if (!twoDates)
                    Flexible(
                      child: Text(
                        date(from.addDays(span ~/ 2)),
                        textAlign: TextAlign.center,
                        style: labelStyle,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      date(to),
                      textAlign: TextAlign.end,
                      style: labelStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Semantics(
      label: moodChartSummary(
        from: from,
        to: to,
        entries: entries,
        smoothing: smoothing,
      ),
      excludeSemantics: true,
      child: chart,
    );
  }
}

/// what screen readers hear for the chart:
/// "Mood chart, October 1 to 29. Average Good, 4.2 of 5. From Okay to
/// Great. 29 days written."
String moodChartSummary({
  required LocalDate from,
  required LocalDate to,
  required Map<LocalDate, DayEntry> entries,
  LmMoodChartSmoothing smoothing = LmMoodChartSmoothing.none,
}) {
  final days = [
    for (final entry in entries.values)
      if (!entry.date.isBefore(from) && !entry.date.isAfter(to))
        entry.moods.average,
  ];
  final title = 'Mood chart, ${_period(from, to)}.';
  if (days.isEmpty) {
    return '$title No day written.';
  }

  final average = days.reduce((a, b) => a + b) / days.length;
  final lowest = moodLabel(moodOfAverage(days.reduce((a, b) => a < b ? a : b)));
  final highest = moodLabel(
    moodOfAverage(days.reduce((a, b) => a > b ? a : b)),
  );
  final count = days.length == 1 ? '1 day' : '${days.length} days';
  final smoothed = switch (smoothing) {
    LmMoodChartSmoothing.none => '',
    LmMoodChartSmoothing.rollingWeek => ' Shown as a 7 day average.',
    LmMoodChartSmoothing.weekly => ' Shown by week.',
    LmMoodChartSmoothing.monthly => ' Shown by month.',
  };

  final range = lowest == highest
      ? 'All days $lowest.'
      : 'From $lowest to $highest.';

  return '$title '
      'Average ${moodLabel(moodOfAverage(average))}, '
      '${averageText(average)} of 5. '
      '$range $count written.$smoothed';
}

// "October 1 to 29", "October 1 to November 29", "December 1, 2026 to …"
String _period(LocalDate from, LocalDate to) {
  // FIXME: english for now, the locale comes with translations
  DateTime asDate(LocalDate day) => DateTime(day.year, day.month, day.day);
  if (from == to) {
    return DateFormat('MMMM d').format(asDate(from));
  }
  if (from.year != to.year) {
    final format = DateFormat('MMMM d, y');
    return '${format.format(asDate(from))} to ${format.format(asDate(to))}';
  }
  final end = from.month == to.month ? DateFormat('d') : DateFormat('MMMM d');
  return '${DateFormat('MMMM d').format(asDate(from))} to '
      '${end.format(asDate(to))}';
}

/// grid, lines and dots of LmMoodChart (not exported)
class MoodChartPainter extends CustomPainter {
  new({
    required this.lines,
    required this.span,
    required this.pad,
    required this.colors,
  });

  final List<List<MoodChartPoint>> lines;

  /// days from the first to the last day of the period
  final int span;

  /// space above 5 and under 1 (half a label)
  final double pad;

  final LmColors colors;

  static const dotRadius = 4.0;
  static const ringWidth = 1.5;
  static const lineWidth = 1.5;

  /// dots stay inside the box at both ends
  static const double inset = dotRadius + ringWidth;

  /// closest two dots can be: a dot and 1 px, so they never touch
  static const double minDotGap = 2 * dotRadius + 1;

  /// true when every dot fits on [width] without touching its neighbour
  /// - depends on the real width: a phone may hide dots a tablet shows
  bool dotsFit(double width) {
    if (span == 0) return true;
    final perDay = (width - 2 * inset) / span;
    for (final line in lines) {
      for (var i = 1; i < line.length; i++) {
        if ((line[i].day - line[i - 1].day) * perDay < minDotGap) return false;
      }
    }
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final showDots = dotsFit(size.width);
    double x(double day) => span == 0
        ? size.width / 2
        : inset + day / span * (size.width - 2 * inset);
    double y(double mood) => pad + (5 - mood) / 4 * (size.height - 2 * pad);

    final grid = Paint()
      ..color = colors.border
      ..strokeWidth = 1;
    for (var mood = 1; mood <= 5; mood++) {
      canvas.drawLine(
        Offset(0, y(mood.toDouble())),
        Offset(size.width, y(mood.toDouble())),
        grid,
      );
    }

    final stroke = Paint()
      ..color = colors.borderStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    for (final line in lines) {
      if (line.length < 2) continue;
      final path = Path()..moveTo(x(line.first.day), y(line.first.mood));
      for (final point in line.skip(1)) {
        path.lineTo(x(point.day), y(point.mood));
      }
      canvas.drawPath(path, stroke);
    }

    for (final line in lines) {
      for (final point in line) {
        // without dots, each line still shows where it starts and ends
        // (a lonely point is both)
        final isEnd = point == line.first || point == line.last;
        if (!showDots && !isEnd) continue;
        final center = Offset(x(point.day), y(point.mood));
        canvas
          ..drawCircle(
            center,
            dotRadius + ringWidth,
            Paint()..color = colors.surface,
          )
          ..drawCircle(
            center,
            dotRadius,
            Paint()..color = colors.moodAverage(point.mood),
          );
        final outline = colors.moodOutline(moodOfAverage(point.mood));
        if (outline != null) {
          canvas.drawCircle(
            center,
            dotRadius - 0.5,
            Paint()
              ..color = outline
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(MoodChartPainter old) {
    return old.lines != lines ||
        old.span != span ||
        old.pad != pad ||
        old.colors != colors;
  }
}
