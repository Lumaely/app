import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/app.dart';
import 'package:lumaely/core/router/app_router.dart';
import 'package:lumaely/core/router/placeholder_page.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely/features/entry/ui/entry_page.dart';
import 'package:lumaely/features/today/ui/today_page.dart';
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
  final noon = DateTime(2026, 10, 29, 12);

  setUpAll(() async => diary = await createTestDiary());
  setUp(() => entries = FakeEntryRepository());

  Future<void> launch(WidgetTester tester) async {
    await launchApp(
      tester,
      () async => VaultOpen(diary),
      entries: entries,
      clock: noon.toUtc,
    );
    await tester.pumpAndSettle();
  }

  Future<void> openToday(WidgetTester tester) async {
    await launch(tester);
    final write = find.descendant(
      of: find.byType(TodayPage),
      matching: find.byType(LmButton),
    );
    // off screen with large text
    await tester.ensureVisible(write);
    await tester.tap(write);
    await tester.pumpAndSettle();
  }

  // as a link would
  Future<void> openPath(WidgetTester tester, String path) async {
    await launch(tester);
    ProviderScope.containerOf(tester.element(find.byType(App)))
        .read(appRouterProvider)
        .go(path);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  Future<void> switchMode(WidgetTester tester) async {
    await tester.tap(find.byTooltip(RegExp('^Mode: ')));
    await tester.pumpAndSettle();
  }

  Future<void> goBack(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
  }

  // the middle of a rail is okay
  Future<void> setDayToOkay(WidgetTester tester) async {
    await switchMode(tester);
    final slider = find.byType(LmMoodSlider);
    await tester.tapAt(
      tester.getTopLeft(slider) + Offset(tester.getSize(slider).width / 2, 24),
    );
    await tester.pump();
  }

  Future<void> goToJournal(WidgetTester tester) async {
    await openToday(tester);
    await setDayToOkay(tester);
    await tapText(tester, 'Next');
  }

  Future<void> goToSaved(WidgetTester tester) async {
    await goToJournal(tester);
    await tapText(tester, 'Skip');
  }

  Future<void> write(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(LmJournalField), text);
    await tester.pump();
  }

  Future<void> showKeyboard(WidgetTester tester) async {
    await tester.tap(find.byType(LmJournalField));
    tester.view.viewInsets = FakeViewPadding(
      bottom: 260 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
  }

  Finder onToday() => find.byType(TodayPage);

  testWidgets('a new day: every moment, all empty', (tester) async {
    await openToday(tester);

    expect(find.text('How did your day feel?'), findsOneWidget);
    expect(find.text('Thursday, October 29'), findsOneWidget);
    final curve = tester.widget<LmMoodCurve>(find.byType(LmMoodCurve));
    expect(curve.moments, Moment.values);
    expect(curve.scores, isEmpty);
    expect(find.byType(LmTabBar), findsNothing);
  });

  testWidgets('Next without a mood asks for one', (tester) async {
    await openToday(tester);

    await tapText(tester, 'Next');

    expect(find.text('Set at least one mood first.'), findsOneWidget);
    expect(entries.saves, 0);

    await setDayToOkay(tester);

    expect(find.text('Set at least one mood first.'), findsNothing);
  });

  testWidgets('Next saves the moods, then asks for the journal', (
    tester,
  ) async {
    await openToday(tester);
    await setDayToOkay(tester);

    expect(find.text('Okay · 3/5'), findsOneWidget);
    await tapText(tester, 'Next');

    expect(entries.days[today]!.moods, const WholeDayMood(MoodScore.okay));
    expect(find.text('Anything about your day?'), findsOneWidget);
    expect(find.byType(LmMoodSlider), findsNothing);
  });

  testWidgets('Finish saves the journal, then shows what was saved', (
    tester,
  ) async {
    await goToJournal(tester);
    await write(tester, 'Long walk');

    await tapText(tester, 'Finish');

    final entry = entries.days[today]!;
    expect(entry.moods, const WholeDayMood(MoodScore.okay));
    expect(entry.journal, 'Long walk');
    expect(find.text('Entry saved'), findsOneWidget);
  });

  testWidgets('Finish without a text is fine', (tester) async {
    await goToJournal(tester);

    await tapText(tester, 'Finish');

    expect(entries.days[today]!.journal, isEmpty);
    expect(find.text('Entry saved'), findsOneWidget);
  });

  testWidgets('Skip keeps the moods, and the journal as it was', (
    tester,
  ) async {
    await entries.save(
      today,
      moods: const WholeDayMood(MoodScore.low),
      journal: 'Rain',
    );
    await openToday(tester);
    await tapText(tester, 'Next');
    expect(find.text('Rain'), findsOneWidget);

    await tapText(tester, 'Skip');

    expect(entries.days[today]!.journal, 'Rain');
    expect(find.text('Entry saved'), findsOneWidget);
  });

  testWidgets('Skip with a new text asks first', (tester) async {
    await goToJournal(tester);
    await write(tester, 'Long walk');

    await tapText(tester, 'Skip');
    expect(find.text('Discard changes?'), findsOneWidget);

    await tapText(tester, 'Cancel');
    expect(find.text('Long walk'), findsOneWidget);

    await tapText(tester, 'Skip');
    await tapText(tester, 'Discard changes');
    expect(entries.days[today]!.journal, isEmpty);
    expect(find.text('Entry saved'), findsOneWidget);
  });

  testWidgets('back from the journal: the moods, the text is kept', (
    tester,
  ) async {
    await goToJournal(tester);
    await write(tester, 'Long walk');

    await goBack(tester);
    expect(find.text('How did your day feel?'), findsOneWidget);
    expect(find.text('Okay · 3/5'), findsOneWidget);

    await tapText(tester, 'Next');
    expect(find.text('Long walk'), findsOneWidget);
    expect(entries.days[today]!.journal, isEmpty);

    // the system back too
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('How did your day feel?'), findsOneWidget);
  });

  testWidgets('leaving with a text not saved asks first', (tester) async {
    await goToJournal(tester);
    await write(tester, 'Long walk');
    await goBack(tester);

    await goBack(tester);

    expect(find.text('Discard changes?'), findsOneWidget);
    expect(find.byType(EntryPage), findsOneWidget);
  });

  testWidgets('a failed save keeps the text on screen', (tester) async {
    await goToJournal(tester);
    await write(tester, 'Long walk');
    entries.saveError = Exception('disk');

    await tapText(tester, 'Finish');
    expect(find.text('Your day could not be saved'), findsOneWidget);

    await tapText(tester, 'OK');
    expect(find.text('Long walk'), findsOneWidget);

    entries.saveError = null;
    await tapText(tester, 'Finish');
    expect(entries.days[today]!.journal, 'Long walk');
    expect(find.text('Entry saved'), findsOneWidget);
  });

  testWidgets('nothing can change while the journal is saving', (tester) async {
    await goToJournal(tester);
    await write(tester, 'Long walk');
    final saved = Completer<void>();
    entries.saved = saved.future;
    await tester.tap(find.text('Finish'));
    await tester.pump();

    expect(
      tester.widget<LmJournalField>(find.byType(LmJournalField)).readOnly,
      isTrue,
    );
    await tester.tap(find.text('Skip'));
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Anything about your day?'), findsOneWidget);

    saved.complete();
    await tester.pumpAndSettle();
    expect(find.text('Entry saved'), findsOneWidget);
  });

  testWidgets('the day saved: its date and its moods', (tester) async {
    await goToSaved(tester);

    expect(find.text('Thursday, October 29'), findsOneWidget);
    expect(find.text('3/5 · Okay'), findsOneWidget);
    expect(find.byType(LmTopBar), findsNothing);
    expect(find.byType(LmProgressSteps), findsNothing);
  });

  testWidgets('Back to today', (tester) async {
    await goToSaved(tester);

    await tapText(tester, 'Back to today');

    expect(find.byType(EntryPage), findsNothing);
    expect(onToday(), findsOneWidget);
  });

  testWidgets('View in journal', (tester) async {
    await goToSaved(tester);

    await tapText(tester, 'View in journal');

    expect(find.byType(EntryPage), findsNothing);
    expect(find.widgetWithText(PlaceholderPage, 'Journal'), findsOneWidget);
  });

  testWidgets('once saved, the system back leaves', (tester) async {
    await goToJournal(tester);
    // a discarded text must not ask again
    await write(tester, 'Long walk');
    await tapText(tester, 'Skip');
    await tapText(tester, 'Discard changes');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsNothing);
    expect(onToday(), findsOneWidget);
  });

  testWidgets('screen readers hear each step as a new page', (tester) async {
    final semantics = tester.ensureSemantics();
    await goToJournal(tester);

    expect(
      tester.getSemantics(find.text('Anything about your day?')),
      isSemantics(isHeader: true, namesRoute: true),
    );

    await tapText(tester, 'Skip');
    expect(
      tester.getSemantics(find.text('Entry saved')),
      isSemantics(isHeader: true, namesRoute: true),
    );
    expect(find.bySemanticsLabel('Mood: Okay, 3 of 5'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a moment can be set alone', (tester) async {
    await openToday(tester);
    tester
        .widget<LmMoodCurve>(find.byType(LmMoodCurve))
        .onChanged(Moment.morning, MoodScore.good);
    await tester.pump();

    await tapText(tester, 'Next');

    expect(
      entries.days[today]!.moods,
      MomentMoods(const {Moment.morning: MoodScore.good}),
    );
  });

  testWidgets('a written day opens with its moods', (tester) async {
    await entries.save(today, moods: const WholeDayMood(MoodScore.low));
    await openToday(tester);

    expect(find.text('Low · 2/5'), findsOneWidget);
  });

  testWidgets('switching mode says what it does, and loses nothing', (
    tester,
  ) async {
    await entries.save(today, moods: const WholeDayMood(MoodScore.low));
    await openToday(tester);

    expect(
      find.byTooltip('Mode: whole day. Switch to by moment'),
      findsOneWidget,
    );
    await switchMode(tester);
    expect(
      find.byTooltip('Mode: by moment. Switch to whole day'),
      findsOneWidget,
    );
    await switchMode(tester);

    expect(find.text('Low · 2/5'), findsOneWidget);
  });

  testWidgets('back without changes leaves at once', (tester) async {
    await openToday(tester);

    await goBack(tester);

    expect(onToday(), findsOneWidget);
  });

  testWidgets('back with changes asks first', (tester) async {
    await openToday(tester);
    await setDayToOkay(tester);

    await goBack(tester);
    expect(find.text('Discard changes?'), findsOneWidget);

    await tapText(tester, 'Cancel');
    expect(find.byType(EntryPage), findsOneWidget);
    expect(find.text('Okay · 3/5'), findsOneWidget);

    await goBack(tester);
    await tapText(tester, 'Discard changes');
    expect(onToday(), findsOneWidget);
    expect(entries.saves, 0);
  });

  testWidgets('the system back asks too', (tester) async {
    await openToday(tester);
    await setDayToOkay(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
    expect(find.byType(EntryPage), findsOneWidget);
  });

  testWidgets('no way out while saving', (tester) async {
    final saved = Completer<void>();
    entries.saved = saved.future;
    await openToday(tester);
    await setDayToOkay(tester);
    await tester.tap(find.text('Next'));
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(EntryPage), findsOneWidget);
    expect(find.text('Discard changes?'), findsNothing);

    await tester.tap(find.byType(LmButton), warnIfMissed: false);
    await tester.pump();
    expect(entries.saves, 1);

    saved.complete();
    await tester.pumpAndSettle();
    expect(find.text('Anything about your day?'), findsOneWidget);
  });

  testWidgets('a failed save keeps the moods on screen', (tester) async {
    entries.saveError = Exception('disk');
    await openToday(tester);
    await setDayToOkay(tester);

    await tapText(tester, 'Next');
    expect(find.text('Your day could not be saved'), findsOneWidget);

    await tapText(tester, 'OK');
    expect(find.text('Okay · 3/5'), findsOneWidget);

    entries.saveError = null;
    await tapText(tester, 'Next');
    expect(find.text('Anything about your day?'), findsOneWidget);
  });

  testWidgets('a past day is named', (tester) async {
    await openPath(tester, RouterPaths.entryOn(today.addDays(-2)));

    expect(find.text('Past day'), findsOneWidget);
    expect(find.text('How did Tuesday feel?'), findsOneWidget);

    await setDayToOkay(tester);
    await tapText(tester, 'Next');
    expect(find.text('Anything about Tuesday?'), findsOneWidget);
    await goBack(tester);

    // opened by its path: back still goes somewhere
    await goBack(tester);
    expect(onToday(), findsOneWidget);
  });

  testWidgets('no such day, or a day to come: back to Today', (tester) async {
    for (final path in [
      RouterPaths.entryOn(today.addDays(1)),
      '/entry/2026-02-30',
      '/entry/hello',
    ]) {
      await openPath(tester, path);

      expect(find.byType(EntryPage), findsNothing, reason: path);
      expect(onToday(), findsOneWidget, reason: path);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('large text fits, and the guidelines are met', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view
      ..physicalSize = const Size(375, 667)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    await openToday(tester);

    for (var mode = 0; mode < 2; mode++) {
      await tapText(tester, 'Next');
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await switchMode(tester);
    }
    semantics.dispose();
  });

  testWidgets('the keyboard leaves the buttons where they are', (tester) async {
    await goToJournal(tester);
    final finish = tester.getRect(find.text('Finish'));

    await showKeyboard(tester);

    expect(tester.getRect(find.text('Finish')), finish);
  });

  testWidgets('a tap outside hides the keyboard', (tester) async {
    await goToJournal(tester);
    await showKeyboard(tester);
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.text('Anything about your day?'));
    await tester.pump();

    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('scrolling the text keeps the keyboard', (tester) async {
    await goToJournal(tester);
    await showKeyboard(tester);
    await write(tester, 'A line\n' * 30);
    await tester.pumpAndSettle();
    final before = tester.getTopLeft(find.byType(LmJournalField)).dy;

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 100));
    await tester.pump();

    expect(
      tester.getTopLeft(find.byType(LmJournalField)).dy,
      greaterThan(before),
    );
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('the journal fits with large text and the keyboard', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view
      ..physicalSize = const Size(375, 667)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await entries.save(today, moods: const WholeDayMood(MoodScore.low));
    final semantics = tester.ensureSemantics();
    await openToday(tester);
    await tapText(tester, 'Next');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    await tester.ensureVisible(find.byType(LmJournalField));
    await write(tester, 'A line\n' * 20);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // what is being written is above the keyboard
    final field = tester.state<EditableTextState>(find.byType(EditableText));
    final caret = field.renderEditable.getLocalRectForCaret(
      field.textEditingValue.selection.extent,
    );
    expect(
      field.renderEditable.localToGlobal(caret.bottomLeft).dy,
      lessThan(667 - 260),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('the day saved fits with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view
      ..physicalSize = const Size(375, 667)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await entries.save(
      today,
      moods: MomentMoods(const {
        Moment.morning: MoodScore.good,
        Moment.night: MoodScore.okay,
      }),
    );
    final semantics = tester.ensureSemantics();
    await openToday(tester);
    await tapText(tester, 'Next');
    await tapText(tester, 'Skip');

    expect(tester.takeException(), isNull);
    expect(find.text('Back to today').hitTestable(), findsOneWidget);
    expect(find.text('View in journal').hitTestable(), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });
}
