import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// one tab of [LmTabBar]
@immutable
final class LmTab {
  const new({required this.icon, required this.label});

  final LmIcons icon;
  final String label;
}

class LmTabBar extends StatelessWidget {
  const new({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<LmTab> tabs;
  final int selectedIndex;

  /// called with the index of the tab tapped, the selected one included
  final ValueChanged<int> onSelected;

  static const height = 64.0;
  static const iconSize = 26.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Color colorOf(Set<WidgetState> states) =>
        states.contains(WidgetState.selected)
        ? colors.actionPrimary
        : colors.textSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(size: iconSize, color: colorOf(states)),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) =>
                LmTypography.labelSmall.copyWith(color: colorOf(states)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
          height: height,
          backgroundColor: colors.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          labelPadding: const EdgeInsets.only(top: 1),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return colors.focus.withValues(alpha: 0.16);
            }
            if (states.contains(WidgetState.pressed)) {
              return colors.textPrimary.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.hovered)) {
              return colors.textPrimary.withValues(alpha: 0.04);
            }
            return null;
          }),
          destinations: [
            for (final tab in tabs)
              NavigationDestination(
                icon: LmIcon(tab.icon),
                label: tab.label,
                tooltip: '',
              ),
          ],
        ),
      ),
    );
  }
}
