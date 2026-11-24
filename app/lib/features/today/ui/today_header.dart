import 'package:intl/intl.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// the name of the app, and the streak
/// - [firstDay]: nothing written yet, "Day 1"
/// - no streak: nothing (a "0 days" would feel like a reproach)
class TodayHeader extends StatelessWidget {
  const new({required this.firstDay, required this.streak, super.key});

  final bool firstDay;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      // the streak goes under the name when both don't fit (big text)
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: LmSpace.s2,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              // up to the middle of the capital: the letters of this font are
              // higher than the middle of their line
              Transform.translate(
                offset: const Offset(0, -2),
                child: const LmLogo(size: 32),
              ),
              Flexible(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Lumaely',
                    style: LmTypography.headlineSmall.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (firstDay)
            const LmPill('Day 1')
          else if (streak > 0)
            LmPill(_streakText, semanticLabel: '$_streakText in a row'),
        ],
      ),
    );
  }

  // FIXME: english for now, translations later
  String get _streakText => streak == 1
      ? '1 day'
      : '${NumberFormat.decimalPattern().format(streak)} days';
}
