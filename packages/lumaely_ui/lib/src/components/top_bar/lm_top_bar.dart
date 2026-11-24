import 'package:lumaely_ui/src/components/icon_button/lm_icon_button.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// top of a page: back, title, and maybe one action on the right
/// - [onBack]: null = disabled (e.g. while saving)
class LmTopBar extends StatelessWidget {
  const new({
    required this.title,
    required this.onBack,
    this.action,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;

  /// usually an [LmIconButton]
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        spacing: LmSpace.s3,
        children: [
          LmIconButton(
            icon: LmIcons.chevronLeft,
            label: 'Back',
            onPressed: onBack,
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: LmTypography.titleLarge.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
