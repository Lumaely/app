import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('screen readers skip it', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: LmThemeData.dawn,
        home: const Scaffold(body: Center(child: LmIconBadge(LmIcons.check))),
      ),
    );

    expect(
      tester.getSize(find.byType(LmIconBadge)),
      const Size.square(LmIconBadge.size),
    );
    expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
    semantics.dispose();
  });
}
