import 'package:go_router/go_router.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

class AppShell extends StatelessWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// same order as the branches in app_router.dart
  // FIXME: english for now, the locale comes with translations
  static const tabs = [
    LmTab(icon: LmIcons.today, label: 'Today'),
    LmTab(icon: LmIcons.journal, label: 'Journal'),
    LmTab(icon: LmIcons.insights, label: 'Insights'),
    LmTab(icon: LmIcons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final current = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: LmTabBar(
        tabs: tabs,
        selectedIndex: current,
        onSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == current),
      ),
    );
  }
}
