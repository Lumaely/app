/// how hard a diary password is to guess
/// [tooShort] and [weak] are refused
///
/// Only the length counts, no forced symbols or digits (NIST SP 800-63B): a
/// long phrase beats a short password full of symbols
///
/// Claude-generated
enum PasswordStrength {
  /// fewer than [minLength] characters
  tooShort,

  /// long enough, but easy to guess: a very common password, one character
  /// repeated, or a straight run like "abcdefghij"
  weak,

  /// [minLength] to 13 characters
  okay,

  /// 14 to 19 characters
  good,

  /// 20 characters or more
  strong;

  /// the strength of [password]
  factory of(String password) {
    final length = password.runes.length;

    if (length < minLength) {
      return tooShort;
    }

    if (_isGuessable(password)) {
      return weak;
    }

    if (length < 14) {
      return okay;
    }

    if (length < 20) {
      return good;
    }

    return strong;
  }

  static const minLength = 10;

  /// true when the password can be used
  bool get isAccepted => index >= okay.index;
}

bool _isGuessable(String password) {
  final lower = password.toLowerCase();

  if (_common.contains(lower)) {
    return true;
  }

  final codes = lower.runes.toList();

  if (codes.every((code) => code == codes.first)) {
    return true;
  }

  for (final step in [1, -1]) {
    var run = true;

    for (var i = 1; i < codes.length && run; i++) {
      run = codes[i] - codes[i - 1] == step;
    }

    if (run) {
      return true;
    }
  }
  return false;
}

// very common passwords of 10 characters or more (the shorter ones are already
// refused), lowercase
const _common = {
  '1234567890',
  '0123456789',
  '1q2w3e4r5t',
  'qwertyuiop',
  'azertyuiop',
  'asdfghjkl;',
  'qwerty1234',
  'qwerty123456',
  'azerty1234',
  'azerty123456',
  'password12',
  'password123',
  'password1234',
  'passw0rd123',
  'motdepasse',
  'motdepasse1',
  'motdepasse123',
  'iloveyou12',
  'iloveyou123',
  'jetaime123',
  'football12',
  'football123',
  'baseball123',
  'superman123',
  'princess12',
  'princess123',
  'sunshine12',
  'sunshine123',
  'welcome123',
  'letmein123',
  'administrator',
  'trustno1234',
  'lumaely123',
  'lumaely1234',
};
