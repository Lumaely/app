import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// week view widget
/// - [isFirstDay]: nothing written yet, says what the circles are for
class ThisWeek extends StatelessWidget {
  const new({
    required this.today,
    required this.entries,
    required this.isFirstDay,
    required this.onDayTap,
    super.key,
  });

  final LocalDate today;

  /// the entries of the week, by date
  final Map<LocalDate, DayEntry> entries;

  final bool isFirstDay;
  final ValueChanged<LocalDate> onDayTap;

  @override
  Widget build(BuildContext context) {
    return LmTileGroup(
      title: 'This week',
      children: [
        Padding(
          padding: const EdgeInsets.all(LmSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: LmSpace.s3,
            children: [
              LmWeekStrip(
                week: today,
                entries: entries,
                today: today,
                onDayTap: onDayTap,
              ),
              if (isFirstDay)
                Text(
                  'Your week fills in as you write.',
                  style: LmTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
