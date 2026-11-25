import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required int rows}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: LmThemeData.dawn,
        home: Scaffold(
          body: ListView(
            children: [
              for (var i = 0; i < rows; i++)
                LmTileSlice(
                  first: i == 0,
                  last: i == rows - 1,
                  child: LmTileRow(title: 'Row $i', onTap: () {}),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<BorderRadius> corners(WidgetTester tester) => [
    for (final material in tester.widgetList<Material>(
      find.descendant(
        of: find.byType(LmTileSlice),
        matching: find.byType(Material),
      ),
    ))
      (material.shape! as RoundedRectangleBorder).borderRadius as BorderRadius,
  ];

  const radius = Radius.circular(LmRadius.tile);

  testWidgets('only the ends of the tile are rounded', (tester) async {
    await pump(tester, rows: 3);

    expect(corners(tester), [
      const BorderRadius.vertical(top: radius),
      BorderRadius.zero,
      const BorderRadius.vertical(bottom: radius),
    ]);
  });

  testWidgets('a single row is rounded everywhere', (tester) async {
    await pump(tester, rows: 1);

    expect(corners(tester), [const BorderRadius.all(radius)]);
    expect(find.byType(LmTileDivider), findsNothing);
  });

  testWidgets('divider between the rows only', (tester) async {
    await pump(tester, rows: 4);

    expect(find.byType(LmTileDivider), findsNWidgets(3));
  });

  testWidgets('looks like a tile group: same height', (tester) async {
    await pump(tester, rows: 3);
    final top = tester.getTopLeft(find.byType(LmTileSlice).first).dy;
    final bottom = tester.getBottomLeft(find.byType(LmTileSlice).last).dy;

    await tester.pumpWidget(
      MaterialApp(
        theme: LmThemeData.dawn,
        home: Scaffold(
          body: ListView(
            children: [
              LmTileGroup(
                children: [
                  for (var i = 0; i < 3; i++)
                    LmTileRow(title: 'Row $i', onTap: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(LmTileGroup)).height, bottom - top);
  });
}
