import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/app.dart';
import 'package:lumaely/core/router/app_router.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely/features/entry/ui/entry_page.dart';
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
    ProviderScope.containerOf(tester.element(find.byType(App)))
        .read(appRouterProvider)
        .go(RouterPaths.journal);
    await tester.pumpAndSettle();
  }

  Future<void> writeDays(Iterable<int> daysAgo) async {
    for (final days in daysAgo) {
      await entries.save(today.addDays(-days), moods: good);
    }
  }

  final list = find.byType(CustomScrollView);

  // the one above the list, not the titles of the list itself
  Finder stickyMonth(String text) => find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is ValueListenableBuilder<double>,
    ),
    matching: find.text(text),
  );

  testWidgets('nothing written: invites to write today', (tester) async {
    await launch(tester);

    expect(find.text('Your journal starts today'), findsOneWidget);
    await tester.tap(find.text('Write today’s entry'));
    await tester.pumpAndSettle();

    expect(tester.widget<EntryPage>(find.byType(EntryPage)).date, today);
  });

  testWidgets('the days by month, newest first', (tester) async {
    await writeDays([0, 2, 29]);
    await launch(tester);

    final texts = [
      'October 2026',
      'Thursday, Oct 29',
      'Tuesday, Oct 27',
      'September 2026',
      'Wednesday, Sep 30',
    ];
    final tops = [
      for (final text in texts) tester.getTopLeft(find.text(text)).dy,
    ];
    expect(tops, [...tops]..sort());
  });

  testWidgets('a divider between the months only', (tester) async {
    await writeDays([0, 2, 29, 60]);
    await launch(tester);

    final dividers = find.byWidgetPredicate(
      (widget) => widget is Divider && widget.indent == null,
    );
    expect(dividers, findsNWidgets(2));
  });

  testWidgets('the month stays at the top, pushed by the next one', (
    tester,
  ) async {
    // all of october, then september
    await writeDays([for (var days = 0; days < 59; days++) days]);
    await launch(tester);
    expect(stickyMonth('October 2026'), findsNothing);

    await tester.drag(list, const Offset(0, -300));
    await tester.pump();
    final top = tester.getTopLeft(list).dy;
    expect(tester.getTopLeft(stickyMonth('October 2026')).dy, top);
    // hides the whole lines, not only what is behind the text
    expect(
      tester
          .getSize(
            find
                .ancestor(
                  of: stickyMonth('October 2026'),
                  matching: find.byType(ColoredBox),
                )
                .first,
          )
          .width,
      tester.getSize(list).width,
    );

    // the title of september, just under the top
    final september = find.text('September 2026');
    await tester.scrollUntilVisible(
      september,
      200,
      scrollable: find.descendant(of: list, matching: find.byType(Scrollable)),
    );
    final scroll = Scrollable.of(tester.element(september.first)).position;
    scroll.jumpTo(scroll.pixels - 10);
    await tester.pump();
    final pushed = tester.getRect(stickyMonth('October 2026'));
    expect(pushed.top, lessThan(top));
    expect(
      pushed.bottom + LmTileGroupTitle.gap,
      tester.getTopLeft(september).dy,
    );

    scroll.jumpTo(scroll.pixels + 50);
    await tester.pump();
    expect(stickyMonth('October 2026'), findsNothing);
    expect(tester.getTopLeft(stickyMonth('September 2026')).dy, top);
  });

  testWidgets(
    'screen readers skip the month at the top, they heard its title',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await writeDays([for (var days = 0; days < 59; days++) days]);
      await launch(tester);

      await tester.drag(list, const Offset(0, -40));
      await tester.pump();

      expect(stickyMonth('October 2026'), findsOneWidget);
      expect(find.bySemanticsLabel('October 2026'), findsNothing);
      semantics.dispose();
    },
  );

  testWidgets('a day opens its entry', (tester) async {
    await writeDays([0, 2]);
    await launch(tester);

    await tester.tap(find.text('Tuesday, Oct 27'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<EntryPage>(find.byType(EntryPage)).date,
      today.addDays(-2),
    );
  });

  testWidgets('follows the diary', (tester) async {
    await writeDays([2]);
    await launch(tester);

    await entries.save(today, moods: good, journal: 'Long walk');
    await tester.pumpAndSettle();
    expect(find.text('Thursday, Oct 29'), findsOneWidget);
    expect(find.text('Long walk'), findsOneWidget);

    await entries.save(today, moods: good, journal: 'Rain');
    await tester.pumpAndSettle();
    expect(find.text('Rain'), findsOneWidget);

    await entries.delete(today);
    await tester.pumpAndSettle();
    expect(find.text('Thursday, Oct 29'), findsNothing);
  });

  testWidgets('many years: only what is on screen is built and read', (
    tester,
  ) async {
    await writeDays([for (var days = 0; days < 2500; days++) days]);
    await launch(tester);

    expect(
      find.byType(LmDayRow, skipOffstage: false).evaluate().length,
      lessThan(40),
    );
    // the week of Today, then the first months
    expect(entries.ranges.length, lessThan(4));

    await tester.fling(list, const Offset(0, -3000), 5000);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byType(LmDayRow, skipOffstage: false).evaluate().length,
      lessThan(40),
    );
  });

  testWidgets('a diary that can’t be read can be tried again', (tester) async {
    entries.readError = Exception('disk');
    await launch(tester);
    expect(find.text('Your diary could not be read.'), findsOneWidget);

    entries.readError = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Your journal starts today'), findsOneWidget);
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

    for (final written in [false, true]) {
      if (written) {
        await writeDays([0, 1, 40]);
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
