import 'package:lumaely/features/entry/application/entry_draft.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// the moods of a draft: one per moment, or one for the whole day
/// - [moments]: the ones the person uses, in the order of the day
/// - [error] shows under the moods
class MoodInput extends StatelessWidget {
  const new({
    required this.draft,
    required this.moments,
    required this.onMomentChanged,
    required this.onDayChanged,
    this.error,
    super.key,
  });

  final EntryDraft draft;
  final List<Moment> moments;
  final void Function(Moment moment, MoodScore score) onMomentChanged;
  final ValueChanged<MoodScore> onDayChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final error = this.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: LmSpace.s4,
      children: [
        if (draft.wholeDay)
          _WholeDay(score: draft.dayScore, onChanged: onDayChanged)
        else
          LmMoodCurve(
            moments: moments,
            scores: draft.momentScores,
            onChanged: onMomentChanged,
          ),
        if (error != null)
          // said by screen readers as soon as it shows
          Semantics(liveRegion: true, child: LmFieldError(error)),
      ],
    );
  }
}

class _WholeDay extends StatelessWidget {
  const new({required this.score, required this.onChanged});

  final MoodScore? score;
  final ValueChanged<MoodScore> onChanged;

  @override
  Widget build(BuildContext context) {
    final score = this.score;

    return Column(
      spacing: LmSpace.s4,
      children: [
        const SizedBox(height: LmSpace.s2),
        LmMoodOrb(score: score),
        ExcludeSemantics(
          child: Text(
            score == null
                ? 'No mood yet'
                : '${moodLabel(score)} · ${score.value}/5',
            textAlign: TextAlign.center,
            style: LmTypography.headlineMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
        LmMoodSlider(score: score, onChanged: onChanged),
      ],
    );
  }
}
