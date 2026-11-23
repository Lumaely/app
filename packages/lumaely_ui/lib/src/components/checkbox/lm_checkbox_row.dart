import 'package:lumaely_ui/src/components/text/lm_field_error.dart';
import 'package:lumaely_ui/src/components/text/lm_line_mark.dart';
import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// checkbox with description
class LmCheckboxRow extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.onChanged,
    this.error,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? error;

  static const boxSize = 22.0;
  static const boxRadius = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = LmTypography.bodyMedium.copyWith(color: colors.textPrimary);

    final row = MergeSemantics(
      child: Semantics(
        checked: value,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: const BorderRadius.all(Radius.circular(LmRadius.small)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: LmSpace.s3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: LmSpace.s3,
                children: [
                  LmLineMark(
                    style: style,
                    size: boxSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: value ? colors.actionPrimary : colors.surface,
                        border: Border.all(
                          color: value
                              ? colors.actionPrimary
                              : colors.borderStrong,
                          width: 1.5,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(boxRadius),
                        ),
                      ),
                      child: value
                          ? Center(
                              child: LmIcon(
                                LmIcons.check,
                                size: 16,
                                color: colors.actionOnPrimary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Expanded(child: Text(label, style: style)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final message = error;

    if (message == null) {
      return row;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [row, LmFieldError(message)],
    );
  }
}
