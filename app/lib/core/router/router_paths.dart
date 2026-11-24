import 'package:lumaely_core/lumaely_core.dart';

abstract final class RouterPaths {
  static const splash = '/';
  static const vaultError = '/vault-error';

  // onboarding
  static const onboarding = '/onboarding';
  static const onboardingStart = '/onboarding/start';
  static const onboardingPassword = '/onboarding/password';
  static const onboardingRecoveryKey = '/onboarding/recovery-key';

  // app
  static const unlock = '/unlock';
  static const today = '/today';
  static const journal = '/journal';
  static const insights = '/insights';
  static const settings = '/settings';

  // entry input flow
  static const entryDate = 'date';
  static const entry = '/entry/:$entryDate';
  static String entryOn(LocalDate date) => '/entry/$date';

  // debug
  static const debug = '/debug';
}
