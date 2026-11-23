import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

final List<String> _words = [for (var i = 1; i <= 24; i++) 'word$i'];

Widget _app({double textScale = 1}) {
  return MaterialApp(
    theme: LmThemeData.dawn,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: SingleChildScrollView(child: LmRecoveryKeyWords(_words)),
      ),
    ),
  );
}

void main() {
  testWidgets('shows every word with its number', (tester) async {
    await tester.pumpWidget(_app());

    for (var i = 1; i <= 24; i++) {
      expect(find.text('word$i'), findsOneWidget);
      expect(find.text('$i'), findsOneWidget);
    }
  });

  testWidgets('two columns: 13 next to 1', (tester) async {
    await tester.pumpWidget(_app());

    expect(
      tester.getTopLeft(find.text('word13')).dy,
      tester.getTopLeft(find.text('word1')).dy,
    );
  });

  testWidgets('one column with large text, nothing cut', (tester) async {
    await tester.pumpWidget(_app(textScale: 2));

    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('word13')).dy,
      greaterThan(tester.getTopLeft(find.text('word12')).dy),
    );
  });

  testWidgets('screen readers hear each word with its number', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app());

    expect(find.bySemanticsLabel('Word 1, word1'), findsOneWidget);
    expect(find.bySemanticsLabel('Word 24, word24'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the words can’t be selected', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.byType(SelectableText), findsNothing);
    expect(find.byType(SelectionArea), findsNothing);
  });
}
