import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// big text field to write the journal of a day
/// - grows with the text
/// - [readOnly]: while saving
class LmJournalField extends StatelessWidget {
  const new({
    this.controller,
    this.readOnly = false,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  static const minLines = 6;

  @override
  Widget build(BuildContext context) {
    // the label is read with the field by screen readers
    return MergeSemantics(
      child: Semantics(
        label: 'Journal',
        // FIXME: the menu of the selected text can send it out of the app
        // (search web, share, translate...), decide what to keep
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          onChanged: onChanged,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          enableIMEPersonalizedLearning: false,
          minLines: minLines,
          maxLines: null,
          style: LmTypography.journal.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
