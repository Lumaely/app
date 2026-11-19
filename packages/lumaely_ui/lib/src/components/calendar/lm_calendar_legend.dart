import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/button/lm_button.dart';
import 'package:lumaely_ui/src/components/mood/lm_mood_dot.dart';
import 'package:lumaely_ui/src/components/mood/lm_mood_labels.dart';
import 'package:lumaely_ui/src/components/sheet/lm_sheet.dart';
import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// "?" for the top bar of the journal: opens the calendar legend
/// - one per screen (month and scrolling calendar), 48 px, named for screen
///   readers by its tooltip
class LmCalendarLegendButton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Calendar legend',
      color: context.colors.textPrimary,
      onPressed: () => showLmCalendarLegend(context),
      icon: const LmIcon(LmIcons.help, size: 22),
    );
  }
}

/// opens the calendar legend in a sheet
Future<void> showLmCalendarLegend(BuildContext context) {
  return showLmSheet<void>(
    context,
    builder: (context) => LmSheet(
      title: 'Calendar legend',
      message:
          'Each dot is one day. Tap a day to open it; past days without '
          'entry can still be written.',
      content: const LmCalendarLegend(),
      actions: [
        LmButton(label: 'Got it', onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}

/// what the dots and marks of a calendar mean
/// - mood colors, journal, today, no entry
/// - photos or videos come with media (not in DayEntry yet)
class LmCalendarLegend extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: LmSpace.s3,
      children: [
        _row(
          context,
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: LmSpace.s1,
            children: [
              for (final score in MoodScore.values)
                LmMoodDot(average: score.value.toDouble(), size: 16),
            ],
          ),
          'Mood of the day, from ${moodLabel(MoodScore.rough)} to '
          '${moodLabel(MoodScore.great)} (the number is the date)',
        ),
        _row(
          context,
          Container(
            width: 8,
            height: 2.5,
            decoration: BoxDecoration(
              color: colors.actionPrimary,
              borderRadius: const BorderRadius.all(Radius.circular(1.25)),
            ),
          ),
          'Journal written',
        ),
        _row(
          context,
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.textPrimary, width: 2),
            ),
          ),
          'Today',
        ),
        _row(context, const LmMoodDot(average: null, size: 16), 'No entry yet'),
      ],
    );
  }

  Widget _row(BuildContext context, Widget key, String label) {
    return Row(
      spacing: LmSpace.s3,
      children: [
        // the key is a picture of the mark, the text says it
        ExcludeSemantics(
          child: SizedBox(
            width: 96,
            child: Align(alignment: Alignment.centerLeft, child: key),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: LmTypography.bodyMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
