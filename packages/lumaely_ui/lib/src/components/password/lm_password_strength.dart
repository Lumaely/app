import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// indicator of the strength of a new password, under its field
class LmPasswordStrength extends StatelessWidget {
  const new(this.strength, {super.key});

  final PasswordStrength strength;

  static const barHeight = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (filled, color, word) = switch (strength) {
      PasswordStrength.tooShort => (0, colors.border, null),
      PasswordStrength.weak => (1, colors.errorText, 'Weak'),
      PasswordStrength.okay => (1, colors.warningText, 'Okay'),
      PasswordStrength.good => (2, colors.successText, 'Good'),
      PasswordStrength.strong => (3, colors.successText, 'Strong'),
    };
    final lengthMet = strength != PasswordStrength.tooShort;
    const rule = 'At least ${PasswordStrength.minLength} characters';

    return Semantics(
      liveRegion: true,
      label: [
        if (word != null) 'Password strength: $word.',
        '$rule: ${lengthMet ? 'done' : 'not yet'}.',
      ].join(' '),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: LmSpace.s2,
        children: [
          Row(
            spacing: LmSpace.s3,
            children: [
              Expanded(
                child: Row(
                  spacing: LmSpace.s1,
                  children: [
                    for (var bar = 0; bar < 3; bar++)
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: bar < filled ? color : colors.border,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(barHeight / 2),
                            ),
                          ),
                          child: const SizedBox(height: barHeight),
                        ),
                      ),
                  ],
                ),
              ),
              if (word != null)
                Text(
                  word,
                  style: LmTypography.labelMedium.copyWith(color: color),
                ),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              if (lengthMet)
                LmIcon(LmIcons.check, size: 16, color: colors.successText)
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.textSecondary, width: 1.5),
                  ),
                  child: const SizedBox.square(dimension: 14),
                ),
              Flexible(
                child: Text(
                  rule,
                  style: LmTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
