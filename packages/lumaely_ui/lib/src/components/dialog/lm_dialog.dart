import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// opens [builder] (usually an [LmDialog]) in the middle of the screen
/// - closes with a tap on the scrim, Escape or the back gesture
Future<T?> showLmDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showDialog<T>(context: context, builder: builder);
}

/// confirmation before something that can't be undone
/// e.g. "Remove MacBook Pro?"
/// - everything else is a sheet (LmSheet)
/// - actions: full width, the action first (LmButtonVariant.danger), then
///   "Cancel" (LmButtonVariant.text)
/// - screen readers announce the title when it opens
class LmDialog extends StatelessWidget {
  const new({
    required this.title,
    required this.message,
    required this.actions,
    super.key,
  });

  final String title;
  final String message;
  final List<Widget> actions;

  /// 310 wide on a phone
  static const maxWidth = 310.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      child: Semantics(
        // like AlertDialog: the dialog is a route named by its title
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: title,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              LmSpace.s5,
              LmSpace.s6,
              LmSpace.s5,
              LmSpace.s3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: LmSpace.s4,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: LmSpace.s2,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: LmTypography.titleLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: LmTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: LmSpace.s1,
                  children: actions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
