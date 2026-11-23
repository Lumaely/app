import 'package:lumaely_ui/src/components/text/lm_line_mark.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// error indicator for any field (textfield, choice...)
class LmFieldError extends StatelessWidget {
  const new(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = LmTypography.bodySmall.copyWith(color: colors.errorText);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: LmSpace.s2,
      children: [
        LmLineMark(
          style: style,
          size: 6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.errorText,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(child: Text(message, style: style)),
      ],
    );
  }
}
