import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely/features/entry/ui/entry_page.dart';
import 'package:lumaely/features/today/ui/today_card.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_entry_repository.dart';
import '../../helpers/fake_vault.dart';
import '../../helpers/test_diary.dart';

void main() {
  late LocalDiary diary;
  late FakeEntryRepository entries;

  final today = LocalDate(2026, 10, 29);
  const good = WholeDayMood(MoodScore.good);

  setUpAll(() async => diary = await createTestDiary());
  setUp(() => entries = FakeEntryRepository());

  Future<void> launch(WidgetTester tester) async {
    await launchApp(
      tester,
      () async => VaultOpen(diary),
      entries: entries,
      clock: DateTime(2026, 10, 29, 12).toUtc,
    );
    await tester.pumpAndSettle();
  }

  MomentMoods moments(Iterable<Moment> written) =>
      MomentMoods({for (final moment in written) moment: MoodScore.good});

  Future<void> writeDays(Iterable<int> daysAgo) async {
    for (final days in daysAgo) {
      await entries.save(today.addDays(-days), moods: good);
    }
  }

  LmButton button(WidgetTester tester) =>
      tester.widget<LmButton>(find.byType(LmButton));

  testWidgets('a new diary: welcome, day 1', (tester) async {
    await launch(tester);

    expect(find.text('Welcome to Lumaely'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
    expect(button(tester).label, 'Write today’s entry');
  });

  testWidgets('today not written yet', (tester) async {
    await writeDays([1]);
    await launch(tester);

    expect(find.text('Today · Thursday, Oct 29'), findsOneWidget);
    expect(find.text('No entry for today yet.'), findsOneWidget);
    expect(button(tester).label, 'Write today’s entry');
  });

  final sentences = {
    [Moment.noon]: 'Noon is written.',
    [Moment.noon, Moment.morning]: 'Morning and noon are written.',
    [Moment.night, Moment.morning, Moment.evening]:
        'Morning, evening and night are written.',
  };
  for (final MapEntry(key: written, value: sentence) in sentences.entries) {
    testWidgets('some moments: $sentence', (tester) async {
      await entries.save(today, moods: moments(written));
      await launch(tester);

      expect(find.text(sentence), findsOneWidget);
      expect(
        find.text('${written.length} of ${Moment.values.length} moments'),
        findsOneWidget,
      );
      expect(button(tester).label, 'Continue today’s entry');
      expect(button(tester).variant, LmButtonVariant.primary);
    });
  }

  final completeDays = {
    'every moment': moments(Moment.values),
    'the whole day': good,
  };
  for (final MapEntry(key: name, value: moods) in completeDays.entries) {
    testWidgets('$name: shows the day', (tester) async {
      await entries.save(today, moods: moods, journal: 'Long walk');
      await launch(tester);

      expect(find.text(moodLine(moods)), findsOneWidget);
      expect(find.text('Long walk'), findsOneWidget);
      expect(
        tester
            .widget<LmMoodDot>(
              find.descendant(
                of: find.byType(TodayCard),
                matching: find.byType(LmMoodDot),
              ),
            )
            .average,
        moods.average,
      );
      expect(button(tester).label, 'Edit today’s entry');
      expect(button(tester).variant, LmButtonVariant.secondary);
    });
  }

  testWidgets('the button opens the entry of today', (tester) async {
    await launch(tester);

    await tester.tap(find.byType(LmButton));
    await tester.pumpAndSettle();

    expect(tester.widget<EntryPage>(find.byType(EntryPage)).date, today);
  });

  testWidgets('this week: its days, monday to sunday', (tester) async {
    await writeDays([0, 2, 5]);
    await launch(tester);

    final strip = tester.widget<LmWeekStrip>(find.byType(LmWeekStrip));
    expect(strip.today, today);
    // 5 days ago was last week
    expect(strip.entries.keys, unorderedEquals([today.addDays(-2), today]));
    expect(find.text('Your week fills in as you write.'), findsNothing);
  });

  testWidgets('this week: a new diary says what it is for', (tester) async {
    await launch(tester);

    expect(find.text('Your week fills in as you write.'), findsOneWidget);
  });

  testWidgets('a day of the week opens its entry', (tester) async {
    await launch(tester);

    await tester.tap(find.text('27'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<EntryPage>(find.byType(EntryPage)).date,
      LocalDate(2026, 10, 27),
    );
  });

  testWidgets('a day to come can’t be opened', (tester) async {
    await launch(tester);

    await tester.tap(find.text('30'));
    await tester.pumpAndSettle();

    expect(find.byType(EntryPage), findsNothing);
  });

  testWidgets('follows the diary', (tester) async {
    await launch(tester);

    await writeDays([0]);
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Lumaely'), findsNothing);
    expect(find.text(moodLine(good)), findsOneWidget);
    expect(find.text('1 day'), findsOneWidget);
  });

  testWidgets('the streak, said in full by screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await writeDays([for (var days = 1; days <= 1200; days++) days]);
    await launch(tester);

    expect(find.text('1,200 days'), findsOneWidget);
    expect(find.bySemanticsLabel('1,200 days in a row'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('no streak: nothing', (tester) async {
    await writeDays([5]);
    await launch(tester);

    expect(find.textContaining(RegExp(r'\bdays?\b')), findsNothing);
    expect(find.text('Day 1'), findsNothing);
  });

  testWidgets('a diary that can’t be read can be tried again', (tester) async {
    entries.readError = Exception('disk');
    await launch(tester);
    expect(find.text('Your diary could not be read.'), findsOneWidget);

    entries.readError = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Lumaely'), findsOneWidget);
  });

  testWidgets('large text fits, and the guidelines are met', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view
      ..physicalSize = const Size(375, 667)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    await launch(tester);

    for (final moods in [null, moments(Moment.values.take(3)), good]) {
      if (moods != null) {
        await entries.save(today, moods: moods, journal: 'Long walk. ' * 20);
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }
    semantics.dispose();
  });
}
