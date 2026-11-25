import 'package:intl/intl.dart';
import 'package:lumaely_core/lumaely_core.dart';

// FIXME: english for now, the locale comes with translations

/// "Thursday, October 29, 2026"
String entryDateText(LocalDate date) =>
    DateFormat('EEEE, MMMM d, y').format(date.toDateTime());

/// the day, in a question: "How did … feel?"
/// - a weekday only says which day it is during its own week
String entryDayName(LocalDate date, {required LocalDate today}) {
  if (date == today) {
    return 'today';
  }

  return date.firstOfWeek == today.firstOfWeek
      ? DateFormat('EEEE').format(date.toDateTime())
      : 'that day';
}
