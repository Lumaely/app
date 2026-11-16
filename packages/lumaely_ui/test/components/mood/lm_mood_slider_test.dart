import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:lumaely_ui/src/components/mood/mood_target.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(20), child: child),
    ),
  );
}

void main() {
  testWidgets('a tap on a step sets that score', (tester) async {
    final semantics = tester.ensureSemantics();
    MoodScore? last;
    await tester.pumpWidget(
      _app(LmMoodSlider(score: null, onChanged: (score) => last = score)),
    );

    // steps go from the knob radius (13) to the other end, 4 gaps
    final rail = tester.getRect(find.byType(MoodTarget));
    const inset = 13.0;
    final good = rail.left + inset + (rail.width - 2 * inset) * 3 / 4;
    await tester.tapAt(Offset(good, rail.center.dy));

    expect(last, MoodScore.good);
    semantics.dispose();
  });

  testWidgets('screen readers get a slider with the score', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(LmMoodSlider(score: MoodScore.low, onChanged: (_) {})),
    );

    expect(
      tester.getSemantics(find.byType(MoodTarget)),
      isSemantics(
        label: 'Mood of the day',
        value: 'Low, 2 of 5',
        isSlider: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('left and right arrows change the score', (tester) async {
    MoodScore? last;
    await tester.pumpWidget(
      _app(
        LmMoodSlider(score: MoodScore.good, onChanged: (score) => last = score),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    expect(last, MoodScore.great);
  });

  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name meets the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          LmMoodSlider(score: MoodScore.okay, onChanged: (_) {}),
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
