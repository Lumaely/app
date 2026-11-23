import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/core/router/placeholder_page.dart';
import 'package:lumaely/data/vault/vault_state.dart';
import 'package:lumaely/features/onboarding/ui/start_page.dart';
import 'package:lumaely/features/onboarding/ui/welcome_page.dart';
import 'package:lumaely_ui/lumaely_ui.dart';

import '../../helpers/fake_vault.dart';

void main() {
  // a new install: no diary yet
  Future<void> openWelcome(WidgetTester tester) async {
    await launchApp(tester, () async => const VaultEmpty());
    await tester.pumpAndSettle();
  }

  Future<void> openStart(WidgetTester tester) async {
    await openWelcome(tester);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
  }

  testWidgets('welcome shows the name, the tagline and get started', (
    tester,
  ) async {
    await openWelcome(tester);

    expect(find.text('Lumaely'), findsOneWidget);
    expect(find.text('Your life. Decoded. Privately.'), findsOneWidget);
    expect(find.byType(LmLogo), findsOneWidget);
    expect(find.byType(LmCoverRise), findsOneWidget);
  });

  testWidgets('get started opens start, back comes back', (tester) async {
    await openStart(tester);

    expect(find.byType(StartPage), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(StartPage), findsNothing);
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('"I’m new" goes on to the diary password', (tester) async {
    await openStart(tester);

    await tester.tap(find.text('I’m new'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is PlaceholderPage && widget.title == 'Diary password',
      ),
      findsOneWidget,
    );
  });

  testWidgets('"I have a diary" says it comes later, and stays', (
    tester,
  ) async {
    await openStart(tester);

    await tester.tap(find.text('I have a diary'));
    await tester.pumpAndSettle();

    expect(find.text('Coming later'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Coming later'), findsNothing);
    expect(find.byType(StartPage), findsOneWidget);
  });

  testWidgets('large text fits on both screens', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await openStart(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('both screens meet the accessibility guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await openWelcome(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });
}
