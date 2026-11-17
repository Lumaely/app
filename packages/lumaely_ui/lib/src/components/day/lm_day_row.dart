import 'package:intl/intl.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/mood/lm_mood_dot.dart';
import 'package:lumaely_ui/src/components/mood/lm_mood_labels.dart';
import 'package:lumaely_ui/src/components/tile/lm_tile_row.dart';
import 'package:material_ui/material_ui.dart';

/// one day in a list (journal, search, bookmarks)
/// - mood dot, date, mood line, first line of the journal
/// - screen readers: "Thursday, October 29. Good, 3.5 of 5. 4 moments.
///   Journal: Long walk…"
/// - put it in an LmTileGroup / LmTile, like any LmTileRow
class LmDayRow extends StatelessWidget {
  const new({required this.entry, this.onTap, super.key});

  final DayEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
    final moods = entry.moods;
    final excerpt = firstLine(entry.journal);

    return LmTileRow(
      leading: LmMoodDot(average: moods.average),
      // FIXME: english for now, the locale comes with translations
      title: DateFormat('EEEE, MMM d').format(date),
      subtitle: moodLine(moods),
      excerpt: excerpt,
      semanticLabel: [
        // full month name: "Oct" is read as a word
        DateFormat('EEEE, MMMM d').format(date),
        moodSemantics(moods),
        if (excerpt != null) 'Journal: $excerpt',
      ].join('. '),
      onTap: onTap,
    );
  }

  /// first line with text, trimmed; null when the journal is empty
  static String? firstLine(String journal) {
    for (final line in journal.split('\n')) {
      final text = line.trim();

      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }
}
