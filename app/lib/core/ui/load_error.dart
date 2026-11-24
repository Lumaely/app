import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// instead of a page whose data could not be read
class LoadError extends StatelessWidget {
  const new({
    required this.message,
    required this.onRetry,
    this.onBack,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  /// null = nowhere to go back to (a tab)
  final VoidCallback? onBack;

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
              message,
              textAlign: TextAlign.center,
              style: LmTypography.bodyLarge.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            LmButton(label: 'Try again', onPressed: onRetry),
            if (onBack != null)
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
