import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(20), child: child),
    ),
  );
}

const List<Moment> _moments = [Moment.morning, Moment.noon, Moment.evening];

void main() {
  testWidgets('a tap sets the score under the finger', (tester) async {
    final semantics = tester.ensureSemantics();
    final changes = <(Moment, MoodScore)>[];
    await tester.pumpWidget(
      _app(
        LmMoodCurve(
          moments: _moments,
          scores: const {},
          onChanged: (moment, score) => changes.add((moment, score)),
        ),
      ),
    );

    // rails go from 20 (great) to 230 (rough) in the column
    final column = tester.getRect(find.bySemanticsLabel('Noon'));
    await tester.tapAt(column.topCenter + const Offset(0, 20));
    await tester.tapAt(column.topCenter + const Offset(0, 230));

    expect(changes, [
      (Moment.noon, MoodScore.great),
      (Moment.noon, MoodScore.rough),
    ]);
    semantics.dispose();
  });

  testWidgets('screen readers get each moment as a slider', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        LmMoodCurve(
          moments: _moments,
          scores: const {Moment.morning: MoodScore.good},
          onChanged: (_, _) {},
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Morning')),
      isSemantics(label: 'Morning', value: 'Good, 4 of 5', isSlider: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Evening')),
      isSemantics(label: 'Evening', value: 'Not set', isSlider: true),
    );
    semantics.dispose();
  });

  testWidgets('arrow keys change the focused moment', (tester) async {
    MoodScore? last;
    await tester.pumpWidget(
      _app(
        LmMoodCurve(
          moments: _moments,
          scores: const {},
          onChanged: (_, score) => last = score,
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

    // an empty moment starts in the middle
    expect(last, MoodScore.okay);
  });

  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name meets the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          LmMoodCurve(
            moments: Moment.values,
            scores: const {
              Moment.morning: MoodScore.low,
              Moment.noon: MoodScore.great,
            },
            onChanged: (_, _) {},
          ),
          theme: theme,
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
