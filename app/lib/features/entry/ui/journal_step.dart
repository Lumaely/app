import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumaely/core/time/today_provider.dart';
import 'package:lumaely/features/entry/application/entry_draft.dart';
import 'package:lumaely/features/entry/application/entry_editor.dart';
import 'package:lumaely/features/entry/ui/entry_step_layout.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

class JournalStep extends ConsumerStatefulWidget {
  const new({
    required this.date,
    required this.draft,
    required this.saving,
    required this.onFinish,
    required this.onSkip,
    required this.onBack,
    super.key,
  });

  final LocalDate date;
  final EntryDraft draft;
  final bool saving;
  final VoidCallback onFinish;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  @override
  ConsumerState<JournalStep> createState() => _JournalStepState();
}

class _JournalStepState extends ConsumerState<JournalStep> {
  // what was typed before going back to the moods is still in the draft
  late final _text = TextEditingController(text: widget.draft.journal);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.date;
    final saving = widget.saving;
    final isToday = date == ref.watch(todayProvider);
    final weekday = DateFormat('EEEE').format(date.toDateTime());

    return EntryStepLayout(
      date: date,
      isToday: isToday,
      step: 2,
      title: isToday ? 'Anything about your day?' : 'Anything about $weekday?',
      onBack: saving ? null : widget.onBack,
      actions: Row(
        spacing: LmSpace.s3,
        children: [
          Expanded(
            child: LmButton(
              label: 'Skip',
              variant: LmButtonVariant.text,
              onPressed: saving ? null : widget.onSkip,
            ),
          ),
          Expanded(
            child: LmButton(
              label: 'Finish',
              loading: saving,
              onPressed: widget.onFinish,
            ),
          ),
        ],
      ),
      child: LmJournalField(
        controller: _text,
        readOnly: saving,
        onChanged: ref.read(entryEditorProvider(date).notifier).setJournal,
      ),
    );
  }
}
