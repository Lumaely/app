import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumaely/data/moments/moments_provider.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// today's entry: invites to write, to go on, or shows the day
/// - [firstDay]: nothing written yet in the whole diary
class TodayCard extends ConsumerWidget {
  const new({
    required this.date,
    required this.entry,
    required this.firstDay,
    required this.onWrite,
    super.key,
  });

  final LocalDate date;

  /// null = today isn't written yet
  final DayEntry? entry;

  final bool firstDay;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = this.entry;
    final total = ref.watch(momentsProvider).length;

    return LmTile(
      child: Padding(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: LmSpace.s5,
          children: switch (entry?.moods) {
            null when firstDay => [
              const _Welcome(),
              LmButton(label: 'Write today’s entry', onPressed: onWrite),
            ],
            null => [
              _Day(date: date, title: 'No entry for today yet.'),
              LmButton(label: 'Write today’s entry', onPressed: onWrite),
            ],
            MomentMoods(:final scores) when scores.length < total => [
              _Day(
                date: date,
                note: '${scores.length} of $total moments',
                title: _writtenText(scores.keys),
              ),
              LmButton(label: 'Continue today’s entry', onPressed: onWrite),
            ],
            final moods => [
              _Day(
                date: date,
                leading: LmMoodDot(average: moods.average, size: 40),
                title: moodLine(moods),
                semanticTitle: moodSemantics(moods),
                journal: entry!.journal,
              ),
              LmButton(
                label: 'Edit today’s entry',
                variant: LmButtonVariant.secondary,
                onPressed: onWrite,
              ),
            ],
          },
        ),
      ),
    );
  }

  /// "Morning is written." / "Morning, noon and night are written."
  // FIXME: english for now, translations later
  static String _writtenText(Iterable<Moment> written) {
    final [first, ...others] = [
      for (final moment in Moment.values)
        if (written.contains(moment)) momentLabel(moment),
    ];

    if (others.isEmpty) {
      return '$first is written.';
    }

    final names = [first, ...others.map((name) => name.toLowerCase())];
    final last = names.removeLast();

    return '${names.join(', ')} and $last are written.';
  }
}

class _Welcome extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome to Lumaely',
          style: LmTypography.headlineSmall.copyWith(color: colors.textPrimary),
        ),
        Text(
          'Your first entry takes about a minute.',
          style: LmTypography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

/// the date, what was written, and how the journal starts
class _Day extends StatelessWidget {
  const new({
    required this.date,
    required this.title,
    this.semanticTitle,
    this.leading,
    this.note,
    this.journal = '',
  });

  final LocalDate date;
  final String title;

  /// read instead of [title] by screen readers
  final String? semanticTitle;

  /// before the date and the title
  final Widget? leading;

  /// on the right of the date
  final String? note;

  final String journal;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final note = this.note;
    final day = DateFormat('EEEE, MMM d').format(date.toDateTime());
    final labelStyle = LmTypography.labelMedium.copyWith(
      color: colors.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: LmSpace.s3,
      children: [
        Row(
          spacing: LmSpace.s3,
          children: [
            ?leading,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: LmSpace.s1,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: LmSpace.s3,
                    children: [
                      Text('Today · $day', style: labelStyle),
                      if (note != null) Text(note, style: labelStyle),
                    ],
                  ),
                  Text(
                    title,
                    semanticsLabel: semanticTitle,
                    style: LmTypography.titleMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (journal.isNotEmpty)
          Text(
            journal,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: LmTypography.journal.copyWith(color: colors.textPrimary),
          ),
      ],
    );
  }
}
