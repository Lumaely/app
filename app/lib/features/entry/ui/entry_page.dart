import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely/features/entry/application/entry_draft.dart';
import 'package:lumaely/features/entry/application/entry_editor.dart';
import 'package:lumaely/features/entry/ui/mood_step.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// writes the day at [date], full screen
/// - Next saves the moods, then goes on
/// - leaving with changes asks first
class EntryPage extends ConsumerStatefulWidget {
  const new({required this.date, super.key});

  final LocalDate date;

  @override
  ConsumerState<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryPage> {
  var _triedOnce = false;
  var _saving = false;

  EntryEditorProvider get _provider => entryEditorProvider(widget.date);

  EntryEditor get _editor => ref.read(_provider.notifier);

  Future<void> _next() async {
    setState(() => _triedOnce = true);

    if (ref.read(_provider).requireValue.moods == null) {
      return;
    }

    setState(() => _saving = true);

    try {
      await _editor.save();
    } on Exception {
      if (!mounted) {
        return;
      }

      setState(() => _saving = false);

      await showLmDialog<void>(
        context,
        builder: (context) => LmDialog(
          title: 'Your day could not be saved',
          message: 'Your moods are still here. Try again in a moment.',
          actions: [
            LmButton(label: 'OK', onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
      return;
    }

    if (mounted) {
      _leave();
    }
  }

  Future<void> _confirmLeave() async {
    final discard = await showLmDialog<bool>(
      context,
      builder: (context) => LmDialog(
        title: 'Discard changes?',
        message: 'Your changes to this entry won’t be saved.',
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

    if (discard == true && mounted) {
      _leave();
    }
  }

  // opened by its path: nothing to go back to
  void _leave() =>
      context.canPop() ? context.pop() : context.go(RouterPaths.today);

  Future<void> _back(EntryDraft draft) async {
    if (draft.hasChanges) {
      await _confirmLeave();
    } else {
      _leave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(_provider);
    final canLeave = !_saving && !(draft.value?.hasChanges ?? false);

    return PopScope(
      canPop: canLeave,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && !_saving) {
          await _confirmLeave();
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: switch (draft) {
          AsyncValue(:final value?) => MoodStep(
            date: widget.date,
            draft: value,
            showErrors: _triedOnce,
            saving: _saving,
            onNext: _next,
            onBack: () => _back(value),
          ),
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
