import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// the journal before the first day is written
class JournalEmpty extends StatelessWidget {
  const new({required this.onWrite, super.key});

  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // centered, and scrolls when it doesn't fit (big text)
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: LmSpace.s8,
          vertical: LmSpace.s5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: LmIconBadge(LmIcons.journal)),
            const SizedBox(height: LmSpace.s4),
            Text(
              'Your journal starts today',
              textAlign: TextAlign.center,
              style: LmTypography.headlineSmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: LmSpace.s1),
            Text(
              'The days you write will be here.',
              textAlign: TextAlign.center,
              style: LmTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: LmSpace.s5),
            LmButton(label: 'Write today’s entry', onPressed: onWrite),
          ],
        ),
      ),
    );
  }
}
