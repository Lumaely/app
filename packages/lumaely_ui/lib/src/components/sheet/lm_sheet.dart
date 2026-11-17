import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// opens [builder] (usually an [LmSheet]) as a bottom sheet
/// - look comes from the theme: surface raised, radius `sheet`, drag handle
/// - closes with the handle, a tap on the scrim, Escape or the back gesture
/// - grows with its content (text scale, keyboard), never above the status
///   bar
Future<T?> showLmSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: true,
    useSafeArea: true,
  );
}

/// content of a bottom sheet: [title], [message], [content], [actions]
/// - for anything that isn't a destructive confirmation (that's LmDialog)
/// - scrolls when too tall (200 % text), stays above the keyboard
/// - actions: full width buttons, main one first, e.g. LmButton
class LmSheet extends StatelessWidget {
  const new({
    required this.title,
    this.message,
    this.content,
    this.actions = const [],
    super.key,
  });

  /// read as a heading by screen readers
  final String title;

  final String? message;

  /// anything between the texts and the actions (tile, field, note...)
  final Widget? content;

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final message = this.message;

    // keyboard: the sheet goes up with it (e.g. "New folder" field)
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: SafeArea(
        top: false,
        // figma: 34 on iphone (home indicator), at least 24 elsewhere
        minimum: const EdgeInsets.only(bottom: LmSpace.s6),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: LmSpace.s6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: LmSpace.s5,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 6,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: LmTypography.headlineSmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (message != null)
                    Text(
                      message,
                      style: LmTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                ],
              ),
              ?content,
              if (actions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: LmSpace.s1,
                  children: actions,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
