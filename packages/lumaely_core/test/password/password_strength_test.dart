import 'package:lumaely_core/lumaely_core.dart';
import 'package:test/test.dart';

void main() {
  test('under the minimum length is too short', () {
    expect(PasswordStrength.of(''), PasswordStrength.tooShort);
    expect(
      PasswordStrength.of('kx7m2pq9w'),
      PasswordStrength.tooShort,
      reason: '${PasswordStrength.minLength - 1} characters',
    );
  });

  test('the longer, the stronger', () {
    expect(PasswordStrength.of('kx7m2pq9wz'), PasswordStrength.okay);
    expect(PasswordStrength.of('kx7m2pq9wzrt5'), PasswordStrength.okay);
    expect(PasswordStrength.of('kx7m2pq9wzrt5v'), PasswordStrength.good);
    expect(PasswordStrength.of('kx7m2pq9wzrt5vb8nc3'), PasswordStrength.good);
    expect(
      PasswordStrength.of('kx7m2pq9wzrt5vb8nc3d'),
      PasswordStrength.strong,
    );
  });

  test('a phrase is enough, no symbols needed', () {
    expect(
      PasswordStrength.of('purple tea on the balcony'),
      PasswordStrength.strong,
    );
  });

  test('easy guesses are weak, whatever their length', () {
    for (final password in [
      'password123',
      'Password123',
      'azertyuiop',
      'motdepasse',
      'aaaaaaaaaaaaaaaaaaaaaaaa',
      'abcdefghijklmnop',
      '9876543210',
    ]) {
      expect(
        PasswordStrength.of(password),
        PasswordStrength.weak,
        reason: password,
      );
    }
  });

  test('an emoji counts as one character', () {
    expect(
      PasswordStrength.of('🌙🌙🌙🌙🌙🌙🌙🌙🌙'),
      PasswordStrength.tooShort,
    );
  });

  test('only okay and above are accepted', () {
    expect(
      {
        for (final strength in PasswordStrength.values)
          strength: strength.isAccepted,
      },
      {
        PasswordStrength.tooShort: false,
        PasswordStrength.weak: false,
        PasswordStrength.okay: true,
        PasswordStrength.good: true,
        PasswordStrength.strong: true,
      },
    );
  });
}
