import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumaely/core/time/clock_provider.dart';
import 'package:lumaely/features/entry/application/entry_draft.dart';
import 'package:lumaely/features/entry/application/entry_editor.dart';
import 'package:lumaely/features/entry/ui/entry_step_layout.dart';
import 'package:lumaely/features/entry/ui/mood_input.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// first step of the entry: the moods of the day
/// - [showErrors]: after the first Next
class MoodStep extends ConsumerWidget {
  const new({
    required this.date,
    required this.draft,
    required this.showErrors,
    required this.saving,
    required this.onNext,
    required this.onBack,
    super.key,
  });

  final LocalDate date;
  final EntryDraft draft;
  final bool showErrors;
  final bool saving;
  final VoidCallback onNext;
  final VoidCallback onBack;

  /// TODO: get user-set setting. For now, all are chosen.
  static const List<Moment> _moments = Moment.values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.read(entryEditorProvider(date).notifier);
    final isToday = date == LocalDate.today(ref.watch(clockProvider));
    final weekday = DateFormat('EEEE').format(date.toDateTime());

    return EntryStepLayout(
      date: date,
      isToday: isToday,
      step: 1,
      title: isToday ? 'How did your day feel?' : 'How did $weekday feel?',
      subtitle: _subtitle,
      onBack: saving ? null : onBack,
      actions: Row(
        spacing: LmSpace.s2,
        children: [
          Expanded(
            child: LmButton(label: 'Next', loading: saving, onPressed: onNext),
          ),
          LmIconButton(
            icon: LmIcons.chevronUpDown,
            label: draft.wholeDay
                ? 'Mode: whole day. Switch to by moment'
                : 'Mode: by moment. Switch to whole day',
            outlined: true,
            onPressed: saving ? null : editor.switchMode,
          ),
        ],
      ),
      child: MoodInput(
        draft: draft,
        moments: _moments,
        onMomentChanged: editor.setMomentScore,
        onDayChanged: editor.setDayScore,
        error: showErrors && draft.moods == null
            ? 'Set at least one mood first.'
            : null,
      ),
    );
  }

  String get _subtitle {
    if (draft.wholeDay) {
      return 'Slide to how your day felt overall.';
    }
    return _moments.every(draft.momentScores.containsKey)
        ? 'Drag each moment up or down.'
        : 'Drag each moment up or down. Empty ones can wait.';
  }
}
