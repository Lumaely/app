import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:material_ui/material_ui.dart';

/// stepped progress indicator
///
/// screen readers reads "Step 1 of 6" (for example)
class LmProgressSteps extends StatelessWidget {
  const new({required this.current, required this.count, super.key})
    : assert(1 <= current && current <= count, 'current is from 1 to count');

  final int current;
  final int count;

  static const height = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      container: true,
      label: 'Step $current of $count',
      child: Row(
        spacing: 6,
        children: [
          for (var step = 1; step <= count; step++)
            Expanded(
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: step <= current ? colors.actionPrimary : colors.border,
                  borderRadius: BorderRadius.circular(LmRadius.full),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
