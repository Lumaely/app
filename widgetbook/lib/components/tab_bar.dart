import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _tabs = [
  LmTab(icon: LmIcons.today, label: 'Today'),
  LmTab(icon: LmIcons.journal, label: 'Journal'),
  LmTab(icon: LmIcons.insights, label: 'Insights'),
  LmTab(icon: LmIcons.settings, label: 'Settings'),
];

@widgetbook.UseCase(name: 'Playground', type: LmTabBar, path: '[Components]')
Widget tabBarPlayground(BuildContext context) {
  final start = context.knobs.object.dropdown(
    label: 'Selected tab',
    options: [for (final tab in _tabs) tab.label],
    labelBuilder: (label) => label,
  );

  // key: picking another tab in the knob starts again from it
  return _TabBarDemo(
    key: ValueKey(start),
    start: _tabs.indexWhere((tab) => tab.label == start),
  );
}

// tapping a tab selects it, as in the app
class _TabBarDemo extends StatefulWidget {
  const new({required this.start, super.key});

  final int start;

  @override
  State<_TabBarDemo> createState() => _TabBarDemoState();
}

class _TabBarDemoState extends State<_TabBarDemo> {
  late int _selected = widget.start;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          _tabs[_selected].label,
          style: LmTypography.titleLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: LmTabBar(
        tabs: _tabs,
        selectedIndex: _selected,
        onSelected: (index) => setState(() => _selected = index),
      ),
    );
  }
}
