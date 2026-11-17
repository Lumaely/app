import 'package:intl/intl.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/calendar/lm_calendar_day.dart';
import 'package:lumaely_ui/src/components/calendar/lm_calendar_legend.dart';
import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// one month of the journal: title, "?" legend button, weeks from monday
/// - pure presentation: entries in, taps out (no database, no state)
/// - [onDayTap] gets past days and today, with or without entry; future
///   days can't be tapped
/// - changing month is the screen's job
class LmMonthCalendar extends StatelessWidget {
  const new({
    required this.year,
    required this.month,
    required this.entries,
    required this.today,
    this.onDayTap,
    super.key,
  });

  final int year;

  /// 1 to 12
  final int month;

  /// the entries of this month, by date (others are ignored)
  final Map<LocalDate, DayEntry> entries;

  /// decides the today ring and which days can be tapped
  final LocalDate today;

  final ValueChanged<LocalDate>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final first = DateTime(year, month);
    // day 0 of next month = last day of this one
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // monday first (figma); blank cells before the 1st
    final blanks = first.weekday - DateTime.monday;
    final weeks = ((blanks + daysInMonth) / 7).ceil();
    final onDayTap = this.onDayTap;

    Widget cell(int index) {
      final day = index - blanks + 1;
      if (day < 1 || day > daysInMonth) {
        return const SizedBox.shrink();
      }
      final date = LocalDate(year, month, day);
      final tappable = onDayTap != null && !date.isAfter(today);
      return LmCalendarDay(
        date: date,
        entry: entries[date],
        isToday: date == today,
        onTap: tappable ? () => onDayTap(date) : null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: LmSpace.s2,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  // FIXME: english for now, the locale comes with translations
                  DateFormat('MMMM y').format(first),
                  style: LmTypography.titleLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Calendar legend',
              color: colors.textSecondary,
              onPressed: () => showLmCalendarLegend(context),
              icon: const LmIcon(LmIcons.help, size: 22),
            ),
          ],
        ),
        // each day says its weekday in full: letters are for the eyes only
        ExcludeSemantics(
          child: Row(
            children: [
              // 2024-01-01 was a monday
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Text(
                    DateFormat('EEEEE').format(DateTime(2024, 1, 1 + i)),
                    textAlign: TextAlign.center,
                    style: LmTypography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (var week = 0; week < weeks; week++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var weekday = 0; weekday < 7; weekday++)
                Expanded(child: cell(week * 7 + weekday)),
            ],
          ),
      ],
    );
  }
}
