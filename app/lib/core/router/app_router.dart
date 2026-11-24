import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:lumaely/core/router/app_shell.dart';
import 'package:lumaely/core/router/placeholder_page.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely/core/router/vault_redirect.dart';
import 'package:lumaely/core/time/clock_provider.dart';
import 'package:lumaely/data/vault/vault.dart';
import 'package:lumaely/debug/vault_debug_page.dart';
import 'package:lumaely/features/entry/ui/entry_page.dart';
import 'package:lumaely/features/launch/ui/splash_page.dart';
import 'package:lumaely/features/launch/ui/vault_error_page.dart';
import 'package:lumaely/features/onboarding/ui/diary_password_page.dart';
import 'package:lumaely/features/onboarding/ui/recovery_key_page.dart';
import 'package:lumaely/features/onboarding/ui/start_page.dart';
import 'package:lumaely/features/onboarding/ui/welcome_page.dart';
import 'package:lumaely/features/today/ui/today_page.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// App router
///
/// - the vault decides where the app can go (vaultRedirect)
/// - a vault change re-runs the redirect; the router, and the pages it keeps,
/// stay
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final vault = ValueNotifier(ref.read(vaultProvider));

  ref
    ..listen(vaultProvider, (_, next) => vault.value = next)
    ..onDispose(vault.dispose);

  LocalDate today() => LocalDate.today(ref.read(clockProvider));

  final router = GoRouter(
    initialLocation: RouterPaths.splash,
    refreshListenable: vault,
    redirect: (context, state) =>
        vaultRedirect(vault.value, state.uri.path, debugBuild: kDebugMode),
    routes: [
      GoRoute(path: RouterPaths.splash, builder: (_, _) => const SplashPage()),
      GoRoute(
        path: RouterPaths.vaultError,
        builder: (_, _) => const VaultErrorPage(),
      ),

      // onboarding: each step is pushed, so back goes to the step before
      GoRoute(
        path: RouterPaths.onboarding,
        builder: (_, _) => const WelcomePage(),
      ),
      GoRoute(
        path: RouterPaths.onboardingStart,
        builder: (_, _) => const StartPage(),
      ),
      GoRoute(
        path: RouterPaths.onboardingPassword,
        builder: (_, _) => const DiaryPasswordPage(),
      ),
      GoRoute(
        path: RouterPaths.onboardingRecoveryKey,
        builder: (_, _) => const RecoveryKeyPage(),
      ),
      // FIXME: placeholders lol
      GoRoute(
        path: RouterPaths.unlock,
        builder: (_, _) => const PlaceholderPage(title: 'Unlock'),
      ),

      // the open diary: four tabs, each with its own history
      // (same order as AppShell.tabs)
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterPaths.today,
                builder: (_, _) => const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterPaths.journal,
                builder: (_, _) => const PlaceholderPage(title: 'Journal'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterPaths.insights,
                builder: (_, _) => const PlaceholderPage(title: 'Insights'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterPaths.settings,
                builder: (_, _) => const PlaceholderPage(title: 'Settings'),
              ),
            ],
          ),
        ],
      ),

      // above the tabs; no such day, or a day to come: back to today
      GoRoute(
        path: RouterPaths.entry,
        redirect: (_, state) {
          final date = _entryDate(state);
          return date == null || date.isAfter(today())
              ? RouterPaths.today
              : null;
        },
        builder: (_, state) => EntryPage(date: _entryDate(state)!),
      ),

      if (kDebugMode)
        GoRoute(
          path: RouterPaths.debug,
          builder: (_, _) => const VaultDebugPage(),
        ),
    ],
  );

  ref.onDispose(router.dispose);

  return router;
}

LocalDate? _entryDate(GoRouterState state) =>
    LocalDate.tryParse(state.pathParameters[RouterPaths.entryDate]!);
