import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/calendar/lm_calendar_day.dart';
import 'package:lumaely_ui/src/components/calendar/lm_weekday_letters.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:material_ui/material_ui.dart';

/// one week, Monday to Sunday, like one row of the month (eg for Today screen)
class LmWeekStrip extends StatelessWidget {
  const new({
    required this.week,
    required this.entries,
    required this.today,
    this.onDayTap,
    super.key,
  });

  /// any day of the week to show (usually today)
  final LocalDate week;

  /// the entries of this week, by date (others are ignored)
  final Map<LocalDate, DayEntry> entries;

  /// decides the today ring and which days can be tapped
  final LocalDate today;

  final ValueChanged<LocalDate>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final monday = week.firstOfWeek;
    final onDayTap = this.onDayTap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: LmSpace.s2,
      children: [
        const LmWeekdayLetters(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Builder(
                  builder: (context) {
                    final date = monday.addDays(i);
                    final tappable = onDayTap != null && !date.isAfter(today);

                    return LmCalendarDay(
                      date: date,
                      entry: entries[date],
                      isToday: date == today,
                      showMark: false,
                      onTap: tappable ? () => onDayTap(date) : null,
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}
