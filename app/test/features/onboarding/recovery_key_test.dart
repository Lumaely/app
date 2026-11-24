import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely/features/onboarding/ui/recovery_key_page.dart';
import 'package:lumaely/features/today/ui/today_page.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';

import '../../helpers/fake_vault.dart';
import '../../helpers/test_diary.dart';

void main() {
  late LocalDiary diary;
  final recoveryKey = RecoveryKey.fromEntropy(
    Uint8List.fromList(List.generate(32, (i) => i * 7)),
  );

  setUpAll(() async => diary = await createTestDiary());

  // a diary just created: the router shows its recovery key
  Future<FakeVault> openRecoveryKey(WidgetTester tester) async {
    final vault = await launchApp(
      tester,
      () async => VaultOpen(diary, newRecoveryKey: recoveryKey),
    );
    await tester.pumpAndSettle();
    return vault;
  }

  Future<void> tapContinue(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  Future<void> checkTheBox(WidgetTester tester) async {
    final box = find.text('I saved my recovery key somewhere safe');
    await tester.ensureVisible(box);
    await tester.tap(box);
    await tester.pump();
  }

  testWidgets('shows the 24 words of the new key', (tester) async {
    await openRecoveryKey(tester);

    expect(find.byType(RecoveryKeyPage), findsOneWidget);
    for (final word in recoveryKey.words.toSet()) {
      expect(find.text(word), findsWidgets, reason: word);
    }
  });

  testWidgets('"?" explains why the key matters', (tester) async {
    await openRecoveryKey(tester);

    await tester.tap(find.byTooltip('Why it matters'));
    await tester.pumpAndSettle();

    expect(find.text('Why your recovery key matters'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.text('Why your recovery key matters'), findsNothing);
  });

  testWidgets('Continue asks for the box first', (tester) async {
    await openRecoveryKey(tester);

    await tapContinue(tester);

    expect(find.text('Check the box once your key is saved.'), findsOneWidget);
    expect(find.text('Did you save your key?'), findsNothing);
  });

  testWidgets('"Go back" keeps the key on screen', (tester) async {
    await openRecoveryKey(tester);
    await checkTheBox(tester);
    await tapContinue(tester);

    await tester.tap(find.text('Go back'));
    await tester.pumpAndSettle();

    expect(find.byType(RecoveryKeyPage), findsOneWidget);
  });

  testWidgets('"Yes, I saved it" confirms the key and opens Today', (
    tester,
  ) async {
    await openRecoveryKey(tester);
    await checkTheBox(tester);
    await tapContinue(tester);

    await tester.tap(find.text('Yes, I saved it'));
    await tester.pump();
    // the confirmation is a real database write: let it happen
    await tester.runAsync(() async {
      while (!await diary.isRecoveryKeyConfirmed()) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await tester.pumpAndSettle();

    expect(find.byType(RecoveryKeyPage), findsNothing);
    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets('large text fits, and the guidelines are met', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final semantics = tester.ensureSemantics();
    await openRecoveryKey(tester);

    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });
}
