// GENERATED CODE - DO NOT MODIFY BY HAND.
// Generated from tokens/tokens.json by tools/tokens_generator.dart.

// ignore_for_file: type=lint

import 'dart:ui';

/// The colors of one theme: Dawn (light) or Firefly (dark).
final class LmColors {
  const new({
    required this.background,
    required this.link,
    required this.focus,
    required this.surface,
    required this.surfaceRaised,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.border,
    required this.borderStrong,
    required this.actionPrimary,
    required this.actionOnPrimary,
    required this.successText,
    required this.successBackground,
    required this.warningText,
    required this.warningBackground,
    required this.errorText,
    required this.errorBackground,
    required this.infoText,
    required this.infoBackground,
    required this.mood1,
    required this.mood2,
    required this.mood3,
    required this.mood4,
    required this.mood5,
    required this.mood1Outline,
    required this.staticWhite,
    required this.staticBlack,
  });

  static const dawn = LmColors(
    background: Color(0xFFFFFBF6),
    link: Color(0xFFB4532A),
    focus: Color(0xFF2E3460),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF2B211C),
    textSecondary: Color(0xFF6E5D52),
    textDisabled: Color(0xFFA8998D),
    border: Color(0xFFEADCC8),
    borderStrong: Color(0xFF9C8676),
    actionPrimary: Color(0xFFB4532A),
    actionOnPrimary: Color(0xFFFFFFFF),
    successText: Color(0xFF2F6B4A),
    successBackground: Color(0xFFE3F1E8),
    warningText: Color(0xFF8A5A00),
    warningBackground: Color(0xFFFCEFD2),
    errorText: Color(0xFFA8323A),
    errorBackground: Color(0xFFFBE4E4),
    infoText: Color(0xFF3E4482),
    infoBackground: Color(0xFFE6E6F5),
    mood1: Color(0xFF2E3460),
    mood2: Color(0xFF6A6496),
    mood3: Color(0xFFB98AA0),
    mood4: Color(0xFFFFA23A),
    mood5: Color(0xFFFFC414),
    mood1Outline: Color(0xFF2E3460),
    staticWhite: Color(0xFFFFFFFF),
    staticBlack: Color(0xFF000000),
  );

  static const firefly = LmColors(
    background: Color(0xFF1B1F3B),
    link: Color(0xFFFFC46B),
    focus: Color(0xFFFFC46B),
    surface: Color(0xFF252A4D),
    surfaceRaised: Color(0xFF2F355C),
    textPrimary: Color(0xFFFFF6E6),
    textSecondary: Color(0xFFB9B4C9),
    textDisabled: Color(0xFF6E6A85),
    border: Color(0xFF3A406B),
    borderStrong: Color(0xFF8287B8),
    actionPrimary: Color(0xFFFFC46B),
    actionOnPrimary: Color(0xFF1B1F3B),
    successText: Color(0xFF8FD4AB),
    successBackground: Color(0xFF1F3A33),
    warningText: Color(0xFFF5B562),
    warningBackground: Color(0xFF3A3022),
    errorText: Color(0xFFFF9C9C),
    errorBackground: Color(0xFF42263A),
    infoText: Color(0xFFB3B7F0),
    infoBackground: Color(0xFF2C3060),
    mood1: Color(0xFF2E3460),
    mood2: Color(0xFF6A6496),
    mood3: Color(0xFFB98AA0),
    mood4: Color(0xFFFFA23A),
    mood5: Color(0xFFFFC414),
    mood1Outline: Color(0xFF8287B8),
    staticWhite: Color(0xFFFFFFFF),
    staticBlack: Color(0xFF000000),
  );

  final Color background;
  final Color link;
  final Color focus;
  final Color surface;
  final Color surfaceRaised;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color border;
  final Color borderStrong;
  final Color actionPrimary;
  final Color actionOnPrimary;
  final Color successText;
  final Color successBackground;
  final Color warningText;
  final Color warningBackground;
  final Color errorText;
  final Color errorBackground;
  final Color infoText;
  final Color infoBackground;
  final Color mood1;
  final Color mood2;
  final Color mood3;
  final Color mood4;
  final Color mood5;

  /// Outline for mood 1 marks. Same as mood 1 in Dawn; lighter in Firefly so the mark reaches 3:1 on the dark background.
  final Color mood1Outline;
  final Color staticWhite;
  final Color staticBlack;

  /// Every token by name, in the order of tokens.json.
  Map<String, Color> get all => {
    'background': background,
    'link': link,
    'focus': focus,
    'surface': surface,
    'surfaceRaised': surfaceRaised,
    'textPrimary': textPrimary,
    'textSecondary': textSecondary,
    'textDisabled': textDisabled,
    'border': border,
    'borderStrong': borderStrong,
    'actionPrimary': actionPrimary,
    'actionOnPrimary': actionOnPrimary,
    'successText': successText,
    'successBackground': successBackground,
    'warningText': warningText,
    'warningBackground': warningBackground,
    'errorText': errorText,
    'errorBackground': errorBackground,
    'infoText': infoText,
    'infoBackground': infoBackground,
    'mood1': mood1,
    'mood2': mood2,
    'mood3': mood3,
    'mood4': mood4,
    'mood5': mood5,
    'mood1Outline': mood1Outline,
    'staticWhite': staticWhite,
    'staticBlack': staticBlack,
  };

  /// The colors between [a] and [b], to animate a theme change.
  static LmColors lerp(LmColors a, LmColors b, double t) {
    return LmColors(
      background: Color.lerp(a.background, b.background, t)!,
      link: Color.lerp(a.link, b.link, t)!,
      focus: Color.lerp(a.focus, b.focus, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceRaised: Color.lerp(a.surfaceRaised, b.surfaceRaised, t)!,
      textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      textDisabled: Color.lerp(a.textDisabled, b.textDisabled, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      borderStrong: Color.lerp(a.borderStrong, b.borderStrong, t)!,
      actionPrimary: Color.lerp(a.actionPrimary, b.actionPrimary, t)!,
      actionOnPrimary: Color.lerp(a.actionOnPrimary, b.actionOnPrimary, t)!,
      successText: Color.lerp(a.successText, b.successText, t)!,
      successBackground: Color.lerp(
        a.successBackground,
        b.successBackground,
        t,
      )!,
      warningText: Color.lerp(a.warningText, b.warningText, t)!,
      warningBackground: Color.lerp(
        a.warningBackground,
        b.warningBackground,
        t,
      )!,
      errorText: Color.lerp(a.errorText, b.errorText, t)!,
      errorBackground: Color.lerp(a.errorBackground, b.errorBackground, t)!,
      infoText: Color.lerp(a.infoText, b.infoText, t)!,
      infoBackground: Color.lerp(a.infoBackground, b.infoBackground, t)!,
      mood1: Color.lerp(a.mood1, b.mood1, t)!,
      mood2: Color.lerp(a.mood2, b.mood2, t)!,
      mood3: Color.lerp(a.mood3, b.mood3, t)!,
      mood4: Color.lerp(a.mood4, b.mood4, t)!,
      mood5: Color.lerp(a.mood5, b.mood5, t)!,
      mood1Outline: Color.lerp(a.mood1Outline, b.mood1Outline, t)!,
      staticWhite: Color.lerp(a.staticWhite, b.staticWhite, t)!,
      staticBlack: Color.lerp(a.staticBlack, b.staticBlack, t)!,
    );
  }
}
