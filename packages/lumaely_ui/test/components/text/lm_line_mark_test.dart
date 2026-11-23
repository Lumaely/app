import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

const _mark = Key('mark');

Widget _app({
  double textScale = 1,
  double size = 6,
  LmLineMarkAlign align = LmLineMarkAlign.lowercase,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Align(
        alignment: Alignment.topLeft,
        child: LmLineMark(
          style: LmTypography.bodySmall,
          size: size,
          align: align,
          child: const ColoredBox(key: _mark, color: Color(0xFFFF0000)),
        ),
      ),
    ),
  );
}

double _markTop(WidgetTester tester) => tester.getTopLeft(find.byKey(_mark)).dy;

void main() {
  testWidgets('keeps the size asked', (tester) async {
    await tester.pumpWidget(_app(size: 20));

    expect(tester.getSize(find.byKey(_mark)), const Size.square(20));
  });

  testWidgets('sits lower than the top of the line', (tester) async {
    await tester.pumpWidget(_app());

    expect(_markTop(tester), greaterThan(0));
  });

  testWidgets('follows the text size', (tester) async {
    await tester.pumpWidget(_app());
    final normal = _markTop(tester);

    await tester.pumpWidget(_app(textScale: 2));

    expect(_markTop(tester), greaterThan(normal));
  });

  testWidgets('on the capitals, a mark sits higher', (tester) async {
    await tester.pumpWidget(_app());
    final lowercase = _markTop(tester);

    await tester.pumpWidget(_app(align: LmLineMarkAlign.capitals));

    expect(_markTop(tester), lessThan(lowercase));
  });
}
