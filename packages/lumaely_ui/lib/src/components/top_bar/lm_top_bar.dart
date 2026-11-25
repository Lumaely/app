import 'package:lumaely_ui/src/components/icon_button/lm_icon_button.dart';
import 'package:lumaely_ui/src/components/text/lm_line_mark.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// top of a page: back, title, and maybe one action on the right
/// - [onBack]: null = disabled (e.g. while saving)
/// - [LmTopBar.tab]: first page of a tab, no back
class LmTopBar extends StatelessWidget {
  const new({required this.title, required this.onBack, this.action, super.key})
    : hasBack = true;

  const new tab({required this.title, this.action, super.key})
    : onBack = null,
      hasBack = false;

  final String title;
  final VoidCallback? onBack;
  final bool hasBack;

  /// usually an [LmIconButton]
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    const style = LmTypography.titleLarge;
    final scaler = MediaQuery.textScalerOf(context);

    // the letters are lower than the middle of their line: moved up, to be
    // centred on the back button
    final lineMiddle = scaler.scale(style.fontSize!) * style.height! / 2;
    final lettersMiddle = LmLineMark.lettersMiddle(
      style,
      scaler: scaler,
      align: LmLineMarkAlign.balanced,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      // as high without back
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        child: Row(
          spacing: LmSpace.s3,
          children: [
            if (hasBack)
              LmIconButton(
                icon: LmIcons.chevronLeft,
                label: 'Back',
                onPressed: onBack,
              ),
            Expanded(
              child: Semantics(
                header: true,
                child: Transform.translate(
                  offset: Offset(0, lineMiddle - lettersMiddle),
                  child: Text(
                    title,
                    style: style.copyWith(color: context.colors.textPrimary),
                  ),
                ),
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}
