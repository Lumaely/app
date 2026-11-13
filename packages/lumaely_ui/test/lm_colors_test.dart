import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely_ui/lumaely_ui.dart';

/// WCAG contrast ratio between two colors, from 1 (same) to 21.
double _contrast(Color a, Color b) {
  final (light, dark) = a.computeLuminance() > b.computeLuminance()
      ? (a, b)
      : (b, a);
  return (light.computeLuminance() + 0.05) / (dark.computeLuminance() + 0.05);
}

void main() {
  const themes = {'Dawn': LmColors.dawn, 'Firefly': LmColors.firefly};

  for (final MapEntry(key: theme, value: c) in themes.entries) {
    group('$theme contrast', () {
      // texts: at least 4.5:1 (WCAG 1.4.3).
      final text = [
        ('primary text on background', c.textPrimary, c.background),
        ('primary text on surface', c.textPrimary, c.surface),
        ('primary text on raised surface', c.textPrimary, c.surfaceRaised),
        ('secondary text on background', c.textSecondary, c.background),
        ('secondary text on surface', c.textSecondary, c.surface),
        ('secondary text on raised surface', c.textSecondary, c.surfaceRaised),
        ('link on background', c.link, c.background),
        ('text on primary action', c.actionOnPrimary, c.actionPrimary),
        ('success text', c.successText, c.successBackground),
        ('warning text', c.warningText, c.warningBackground),
        ('error text', c.errorText, c.errorBackground),
        ('info text', c.infoText, c.infoBackground),
      ];

      // borders, focus rings and controls: at least 3:1 (WCAG 1.4.11).
      final nonText = [
        ('strong border on background', c.borderStrong, c.background),
        ('strong border on surface', c.borderStrong, c.surface),
        ('focus ring on background', c.focus, c.background),
        ('focus ring on surface', c.focus, c.surface),
        ('primary action on background', c.actionPrimary, c.background),
        ('mood 1 outline on background', c.mood1Outline, c.background),
      ];

      for (final (name, foreground, background) in text) {
        test('$name is at least 4.5:1', () {
          expect(_contrast(foreground, background), greaterThanOrEqualTo(4.5));
        });
      }
      for (final (name, foreground, background) in nonText) {
        test('$name is at least 3:1', () {
          expect(_contrast(foreground, background), greaterThanOrEqualTo(3));
        });
      }
    });
  }
}
