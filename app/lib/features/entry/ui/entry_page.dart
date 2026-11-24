import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely/features/entry/application/entry_editor.dart';
import 'package:lumaely/features/entry/ui/journal_step.dart';
import 'package:lumaely/features/entry/ui/mood_step.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// the steps of the entry flow, in order
enum _EntryStep { mood, journal }

/// writes the day at [date], full screen
/// - Next saves the moods, Finish saves the journal
/// - leaving with changes asks first
class EntryPage extends ConsumerStatefulWidget {
  const new({required this.date, super.key});

  final LocalDate date;

  @override
  ConsumerState<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryPage> {
  _EntryStep _step = _EntryStep.mood;
  var _triedNext = false;
  var _saving = false;

  EntryEditorProvider get _provider => entryEditorProvider(widget.date);

  EntryEditor get _editor => ref.read(_provider.notifier);

  Future<void> _next() async {
    setState(() => _triedNext = true);

    if (ref.read(_provider).requireValue.moods == null) {
      return;
    }

    if (await _save(_editor.saveMoods) && mounted) {
      setState(() => _step = _EntryStep.journal);
    }
  }

  Future<void> _finish() async {
    if (await _save(_editor.saveJournal) && mounted) {
      _leave();
    }
  }

  Future<void> _skip() async {
    final draft = ref.read(_provider).requireValue;

    if (!draft.hasJournalChanges ||
        await _confirmDiscard('What you wrote here won’t be saved.')) {
      _leave();
    }
  }

  /// whether it was saved, says so if it wasn't
  Future<bool> _save(Future<void> Function() save) async {
    setState(() => _saving = true);

    try {
      await save();
    } on Exception {
      if (mounted) {
        setState(() => _saving = false);

        await showLmDialog<void>(
          context,
          builder: (context) => LmDialog(
            title: 'Your day could not be saved',
            message: 'Your changes are still here. Try again in a moment.',
            actions: [
              LmButton(label: 'OK', onPressed: () => Navigator.pop(context)),
            ],
          ),
        );
      }
      return false;
    }

    if (mounted) {
      setState(() => _saving = false);
    }

    return true;
  }

  Future<bool> _confirmDiscard(String message) async {
    final discard = await showLmDialog<bool>(
      context,
      builder: (context) => LmDialog(
        title: 'Discard changes?',
        message: message,
        actions: [
          LmButton(
            label: 'Discard changes',
            variant: LmButtonVariant.danger,
            onPressed: () => Navigator.pop(context, true),
          ),
          LmButton(
            label: 'Cancel',
            variant: LmButtonVariant.text,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  void _leave() {
    if (!mounted) {
      return;
    }

    // opened by its path: nothing to go back to
    context.canPop() ? context.pop() : context.go(RouterPaths.today);
  }

  /// one step back, or out of the page from the first one
  Future<void> _back() async {
    if (_step == _EntryStep.journal) {
      setState(() => _step = _EntryStep.mood);
      return;
    }

    final hasChanges = ref.read(_provider).value?.hasChanges ?? false;

    if (!hasChanges ||
        await _confirmDiscard('Your changes to this entry won’t be saved.')) {
      _leave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(_provider);
    final canLeave =
        _step == _EntryStep.mood &&
        !_saving &&
        !(draft.value?.hasChanges ?? false);

    return PopScope(
      canPop: canLeave,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && !_saving) {
          await _back();
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.surface,
        // see EntryStepLayout
        resizeToAvoidBottomInset: false,
        body: switch (draft) {
          AsyncValue(:final value?) => switch (_step) {
            _EntryStep.mood => MoodStep(
              date: widget.date,
              draft: value,
              showErrors: _triedNext,
              saving: _saving,
              onNext: _next,
              onBack: _back,
            ),
            _EntryStep.journal => JournalStep(
              date: widget.date,
              draft: value,
              saving: _saving,
              onFinish: _finish,
              onSkip: _skip,
              onBack: _back,
            ),
          },
          AsyncValue(hasError: true) => _LoadError(
            onRetry: () => ref.invalidate(_provider),
            onBack: _leave,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const new({required this.onRetry, required this.onBack});

  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: LmSpace.s4,
          children: [
            Text(
              'This day could not be read.',
              textAlign: TextAlign.center,
              style: LmTypography.bodyLarge.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            LmButton(label: 'Try again', onPressed: onRetry),
            LmButton(
              label: 'Back',
              variant: LmButtonVariant.text,
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}
