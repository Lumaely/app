import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/core/router/placeholder_page.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely/features/onboarding/ui/diary_password_page.dart';
import 'package:lumaely/features/onboarding/ui/recovery_key_page.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_vault.dart';
import '../../helpers/test_diary.dart';

void main() {
  late LocalDiary diary;

  setUpAll(() async => diary = await createTestDiary());

  // a new install, already on the password step
  // - [createError]: what creating the diary throws, if anything
  // - [created]: completes the creation, to see what happens meanwhile
  // - [afterReload]: what the vault loads the second time
  Future<List<String>> openPasswordStep(
    WidgetTester tester, {
    Exception? createError,
    Future<void>? created,
    VaultState afterReload = const VaultEmpty(),
  }) async {
    final passwords = <String>[];
    var loads = 0;
    await launchApp(
      tester,
      () async => loads++ == 0 ? const VaultEmpty() : afterReload,
      onCreate: (password) async {
        passwords.add(password);
        await created;
        if (createError != null) throw createError;
        return VaultOpen(
          diary,
          newRecoveryKey: RecoveryKey.fromEntropy(Uint8List(32)),
        );
      },
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    // off screen with large text
    await tester.ensureVisible(find.text('I’m new'));
    await tester.tap(find.text('I’m new'));
    await tester.pumpAndSettle();
    return passwords;
  }

  Future<void> type(
    WidgetTester tester,
    String password,
    String confirm,
  ) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), password);
    await tester.enterText(fields.at(1), confirm);
    await tester.pump();
  }

  Future<void> tapContinue(WidgetTester tester) async {
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  testWidgets('the strength follows what is typed', (tester) async {
    await openPasswordStep(tester);

    await type(tester, 'kx7m2pq9wzrt5v', '');

    expect(find.text('Good'), findsOneWidget);
  });

  testWidgets('no error before Continue is tapped', (tester) async {
    await openPasswordStep(tester);

    await type(tester, 'short', 'other');

    expect(find.text('Use at least 10 characters.'), findsNothing);
    expect(find.text('The passwords don’t match.'), findsNothing);
  });

  testWidgets('a short password is refused', (tester) async {
    final passwords = await openPasswordStep(tester);

    await type(tester, 'short', 'short');
    await tapContinue(tester);

    expect(find.text('Use at least 10 characters.'), findsOneWidget);
    expect(passwords, isEmpty);
  });

  testWidgets('an easy guess is refused', (tester) async {
    final passwords = await openPasswordStep(tester);

    await type(tester, 'password123', 'password123');
    await tapContinue(tester);

    expect(find.text('This password is too easy to guess.'), findsOneWidget);
    expect(passwords, isEmpty);
  });

  testWidgets('both fields must match', (tester) async {
    final passwords = await openPasswordStep(tester);

    await type(tester, 'purple tea on the balcony', 'purple tea');
    await tapContinue(tester);

    expect(find.text('The passwords don’t match.'), findsOneWidget);
    expect(passwords, isEmpty);
  });

  testWidgets('errors follow the typing after a try', (tester) async {
    await openPasswordStep(tester);
    await type(tester, 'purple tea on the balcony', 'purple tea');
    await tapContinue(tester);

    await type(
      tester,
      'purple tea on the balcony',
      'purple tea on the balcony',
    );

    expect(find.text('The passwords don’t match.'), findsNothing);
  });

  testWidgets('Continue creates the diary, then shows its recovery key', (
    tester,
  ) async {
    final passwords = await openPasswordStep(tester);

    await type(
      tester,
      'purple tea on the balcony',
      'purple tea on the balcony',
    );
    await tapContinue(tester);

    expect(passwords, ['purple tea on the balcony']);
    expect(find.byType(DiaryPasswordPage), findsNothing);
    expect(find.byType(RecoveryKeyPage), findsOneWidget);
  });

  testWidgets('a failed creation says so and stays', (tester) async {
    await openPasswordStep(tester, createError: Exception('unknown'));

    await type(
      tester,
      'purple tea on the balcony',
      'purple tea on the balcony',
    );
    await tapContinue(tester);

    expect(find.text('Your diary could not be created'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(DiaryPasswordPage), findsOneWidget);
  });

  testWidgets('large text fits, and the guidelines are met', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final semantics = tester.ensureSemantics();
    await openPasswordStep(tester);

    expect(find.byType(DiaryPasswordPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  Future<void> createWith(WidgetTester tester) async {
    await type(
      tester,
      'purple tea on the balcony',
      'purple tea on the balcony',
    );
    await tapContinue(tester);
  }

  testWidgets('a full phone says so', (tester) async {
    await openPasswordStep(
      tester,
      createError: const NotEnoughSpaceException(),
    );

    await createWith(tester);

    expect(find.text('Your phone is full'), findsOneWidget);
  });

  testWidgets('a refused secure storage says so', (tester) async {
    await openPasswordStep(
      tester,
      createError: const MasterKeyCacheException(),
    );

    await createWith(tester);

    expect(find.text('Secure storage isn’t available'), findsOneWidget);
  });

  testWidgets('a diary already there: the vault reloads, then unlock', (
    tester,
  ) async {
    await openPasswordStep(
      tester,
      createError: const DiaryAlreadyExistsException(),
      afterReload: const VaultLocked(),
    );

    await createWith(tester);

    expect(find.byType(DiaryPasswordPage), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is PlaceholderPage && widget.title == 'Unlock',
      ),
      findsOneWidget,
    );
  });

  testWidgets('while creating: back is blocked, readers are told', (
    tester,
  ) async {
    final creation = Completer<void>();
    await openPasswordStep(tester, created: creation.future);
    await type(
      tester,
      'purple tea on the balcony',
      'purple tea on the balcony',
    );

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(
      tester.takeAnnouncements().map((announcement) => announcement.message),
      contains('Creating your diary'),
    );

    bool canGoBack() => tester
        .widget<PopScope>(
          find.descendant(
            of: find.byType(DiaryPasswordPage),
            matching: find.byWidgetPredicate((widget) => widget is PopScope),
          ),
        )
        .canPop;

    expect(canGoBack(), isFalse);

    creation.complete();
    await tester.pumpAndSettle();

    expect(find.byType(RecoveryKeyPage), findsOneWidget);
  });
}
