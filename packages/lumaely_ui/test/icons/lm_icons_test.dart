import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';

void main() {
  // a broken svg path would throw while painting
  testWidgets('every icon draws', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Wrap(children: [for (final icon in LmIcons.values) LmIcon(icon)]),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(LmIcon), findsNWidgets(LmIcons.values.length));
  });

  testWidgets('takes its size from the icon theme, like Icon', (tester) async {
    const size = 18.0;
    await tester.pumpWidget(
      const Center(
        child: IconTheme(
          data: IconThemeData(size: size),
          child: LmIcon(LmIcons.trash),
        ),
      ),
    );

    expect(tester.getSize(find.byType(LmIcon)), const Size.square(size));
  });

  testWidgets('screen readers skip it unless it has a label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            LmIcon(LmIcons.trash),
            LmIcon(LmIcons.lock, semanticLabel: 'Locked'),
          ],
        ),
      ),
    );

    expect(find.bySemanticsLabel('Locked'), findsOneWidget);
    semantics.dispose();
  });

  // two names on the same svg = copy paste mistake
  test('no two icons share a path', () {
    final paths = LmIcons.values.map((icon) => icon.path);
    expect(paths.toSet(), hasLength(LmIcons.values.length));
  });
}
