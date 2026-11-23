import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(PasswordStrength strength, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LmThemeData.dawn,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LmPasswordStrength(strength),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the word of each strength', (tester) async {
    for (final (strength, word) in [
      (PasswordStrength.weak, 'Weak'),
      (PasswordStrength.okay, 'Okay'),
      (PasswordStrength.good, 'Good'),
      (PasswordStrength.strong, 'Strong'),
    ]) {
      await tester.pumpWidget(_app(strength));

      expect(find.text(word), findsOneWidget, reason: '$strength');
    }
  });

  testWidgets('too short: no word, the rule is not checked yet', (
    tester,
  ) async {
    await tester.pumpWidget(_app(PasswordStrength.tooShort));

    expect(find.text('Okay'), findsNothing);
    expect(find.byType(LmIcon), findsNothing);
    expect(find.text('At least 10 characters'), findsOneWidget);
  });

  testWidgets('the rule gets a check once the length is met', (tester) async {
    await tester.pumpWidget(_app(PasswordStrength.okay));

    expect(find.byType(LmIcon), findsOneWidget);
  });

  testWidgets('screen readers hear one sentence', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(PasswordStrength.good));

    expect(
      tester.getSemantics(find.byType(LmPasswordStrength)),
      isSemantics(
        label: 'Password strength: Good. At least 10 characters: done.',
        isLiveRegion: true,
      ),
    );
    semantics.dispose();
  });

  final themes = {'Dawn': LmThemeData.dawn, 'Firefly': LmThemeData.firefly};
  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('$name: every word is readable', (tester) async {
      final semantics = tester.ensureSemantics();
      for (final strength in PasswordStrength.values) {
        await tester.pumpWidget(_app(strength, theme: theme));

        await expectLater(tester, meetsGuideline(textContrastGuideline));
      }
      semantics.dispose();
    });
  }
}
