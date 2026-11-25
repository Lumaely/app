import 'package:intl/intl.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// end of the entry flow - summary
class EntrySavedStep extends StatelessWidget {
  const new({
    required this.date,
    required this.moods,
    required this.onToday,
    required this.onJournal,
    super.key,
  });

  final LocalDate date;
  final DayMoods moods;
  final VoidCallback onToday;
  final VoidCallback onJournal;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LmSpace.s5,
            LmSpace.s2,
            LmSpace.s5,
            LmSpace.s5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: LmSpace.s4,
            children: [
              Expanded(
                // centered, and scrolls when it doesn't fit (big text)
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: LmIconBadge(LmIcons.check)),
                        const SizedBox(height: LmSpace.s4),
                        _Title(date: date),
                        const SizedBox(height: LmSpace.s8),
                        // one row per part of the day
                        LmTileGroup(
                          children: [
                            LmTileRow(
                              title: 'Mood',
                              value: moodLine(moods),
                              semanticLabel: 'Mood: ${moodSemantics(moods)}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: LmSpace.s1,
                children: [
                  LmButton(label: 'Back to today', onPressed: onToday),
                  LmButton(
                    label: 'View in journal',
                    variant: LmButtonVariant.text,
                    onPressed: onJournal,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const new({required this.date});

  final LocalDate date;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: LmSpace.s1,
      children: [
        Semantics(
          header: true,
          namesRoute: true,
          child: Text(
            'Entry saved',
            textAlign: TextAlign.center,
            style: LmTypography.headlineLarge.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        Text(
          DateFormat('EEEE, MMMM d').format(date.toDateTime()),
          textAlign: TextAlign.center,
          style: LmTypography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
