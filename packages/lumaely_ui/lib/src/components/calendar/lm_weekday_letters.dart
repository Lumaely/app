import 'package:intl/intl.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// "M T W T F S S" above the days of a calendar (month or week)
class LmWeekdayLetters extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Text(
                // FIXME: english for now, the locale comes with translations
                DateFormat('EEEEE').format(DateTime(2024, 1, 1 + i)),
                textAlign: TextAlign.center,
                style: LmTypography.labelSmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
