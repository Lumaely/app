import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/core/router/placeholder_page.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely/features/launch/ui/splash_page.dart';
import 'package:lumaely/features/launch/ui/vault_error_page.dart';
import 'package:lumaely/features/onboarding/ui/welcome_page.dart';
import 'package:lumaely/features/today/ui/today_page.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:lumaely_ui/lumaely_ui.dart';

import '../../helpers/fake_vault.dart';
import '../../helpers/test_diary.dart';

void main() {
  late LocalDiary diary;

  setUpAll(() async => diary = await createTestDiary());

  Future<FakeVault> launch(
    WidgetTester tester,
    Future<VaultState> Function() load,
  ) => launchApp(tester, load);

  Finder placeholder(String title) => find.byWidgetPredicate(
    (widget) => widget is PlaceholderPage && widget.title == title,
  );

  testWidgets('shows the splash while the vault loads', (tester) async {
    await launch(tester, () => Completer<VaultState>().future);
    await tester.pump();

    expect(find.byType(SplashPage), findsOneWidget);
  });

  testWidgets('no diary: lands on onboarding', (tester) async {
    await launch(tester, () async => const VaultEmpty());
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('locked diary: lands on unlock', (tester) async {
    await launch(tester, () async => const VaultLocked());
    await tester.pumpAndSettle();

    expect(placeholder('Unlock'), findsOneWidget);
  });

  testWidgets('open diary: lands on today', (tester) async {
    await launch(tester, () async => VaultOpen(diary));
    await tester.pumpAndSettle();

    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets('follows the vault: unlocking moves to today', (tester) async {
    final vault = await launch(tester, () async => const VaultLocked());
    await tester.pumpAndSettle();

    vault.set(VaultOpen(diary));
    await tester.pumpAndSettle();

    expect(placeholder('Unlock'), findsNothing);
    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets('vault error: retry reloads the vault and moves on', (
    tester,
  ) async {
    var loads = 0;
    await launch(tester, () async {
      loads++;
      if (loads == 1) throw StateError('keychain unavailable');
      return const VaultEmpty();
    });
    await tester.pumpAndSettle();

    expect(find.byType(VaultErrorPage), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(loads, 2);
    expect(find.byType(VaultErrorPage), findsNothing);
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('the tab bar shows only once the diary is open', (tester) async {
    final vault = await launch(tester, () async => const VaultEmpty());
    await tester.pumpAndSettle();

    expect(find.byType(LmTabBar), findsNothing);

    vault.set(VaultOpen(diary));
    await tester.pumpAndSettle();

    expect(find.byType(LmTabBar), findsOneWidget);
  });

  testWidgets('tapping a tab shows its page', (tester) async {
    await launch(tester, () async => VaultOpen(diary));
    await tester.pumpAndSettle();
    Finder tab(String label) =>
        find.descendant(of: find.byType(LmTabBar), matching: find.text(label));

    for (final label in ['Journal', 'Insights', 'Settings']) {
      await tester.tap(tab(label));
      await tester.pumpAndSettle();

      expect(placeholder(label), findsOneWidget, reason: label);
    }

    await tester.tap(tab('Today'));
    await tester.pumpAndSettle();

    expect(find.byType(TodayPage), findsOneWidget);
  });
}
