// Claude-generated
import 'dart:convert';
import 'dart:io';

/// Generates the design tokens of lumaely_ui, in Dart, from
/// `tokens/tokens.json` (W3C Design Tokens format, exported from Figma).
///
/// Run it from `packages/lumaely_ui`: `dart run tools/tokens_generator.dart`.
void main() {
  final json = jsonDecode(
    File('tokens/tokens.json').readAsStringSync(),
  ) as Map<String, Object?>;

  final tokens = <Token>[];
  _collect(json, path: const [], type: null, into: tokens);
  final byPath = {for (final token in tokens) token.path.join('.'): token};

  final files = {
    'lib/src/tokens/lm_colors.dart': _colorsFile(tokens, byPath),
    'lib/src/tokens/lm_layout.dart': _layoutFile(tokens),
    'lib/src/tokens/lm_typography.dart': _typographyFile(tokens, byPath),
  };
  for (final MapEntry(key: path, value: content) in files.entries) {
    File(path)
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  // Formats with the Dart SDK running this script, so CI's format check passes.
  final format = Process.runSync(Platform.resolvedExecutable, [
    'format',
    ...files.keys,
  ]);
  if (format.exitCode != 0) {
    stderr.write(format.stderr);
    exit(format.exitCode);
  }
  stdout.writeln('Generated ${files.length} files.');
}

const _header = '''
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Generated from tokens/tokens.json by tools/tokens_generator.dart.

// ignore_for_file: type=lint

''';

/// One design token: where it is in the file, its type and its raw value.
class Token {
  const new({
    required this.path,
    required this.type,
    required this.value,
    this.description,
  });

  final List<String> path;
  final String type;
  final Object? value;
  final String? description;
}

/// Walks a group of the JSON tree and adds every token it finds to [into].
///
/// [type] is the `$type` inherited from the parent groups.
void _collect(
  Map<String, Object?> group, {
  required List<String> path,
  required String? type,
  required List<Token> into,
}) {
  final groupType = group[r'$type'] as String? ?? type;

  for (final entry in group.entries) {
    if (entry.key.startsWith(r'$')) {
      continue;
    }
    final child = entry.value! as Map<String, Object?>;
    final childPath = [...path, entry.key];

    if (child.containsKey(r'$value')) {
      final tokenType = child[r'$type'] as String? ?? groupType;
      if (tokenType == null) {
        throw FormatException('No \$type for ${childPath.join('.')}');
      }
      into.add(
        Token(
          path: childPath,
          type: tokenType,
          value: child[r'$value'],
          description: child[r'$description'] as String?,
        ),
      );
    } else {
      _collect(child, path: childPath, type: groupType, into: into);
    }
  }
}

/// [value], with aliases such as `{color.dawn.mood.1}` replaced by the value
/// they point to.
Object? _resolve(Object? value, Map<String, Token> byPath) {
  if (value is String && value.startsWith('{') && value.endsWith('}')) {
    final target = byPath[value.substring(1, value.length - 1)];
    if (target == null) {
      throw FormatException('Unknown alias $value');
    }
    return _resolve(target.value, byPath);
  }
  return value;
}

/// `['action', 'on-primary']` becomes `actionOnPrimary`. A segment repeating
/// the one before is dropped: `['surface', 'surface']` becomes `surface`.
String _camelCase(List<String> path) {
  final words = [
    for (final (index, segment) in path.indexed)
      if (index == 0 || segment != path[index - 1]) ...segment.split('-'),
  ];
  return '${words.first}${words.skip(1).map(_capitalize).join()}';
}

String _capitalize(String word) =>
    '${word[0].toUpperCase()}${word.substring(1)}';

/// `Color(0xAARRGGBB)` for a W3C color value.
String _dartColor(Object? value) {
  final color = value! as Map<String, Object?>;
  final hex = (color['hex']! as String).substring(1);
  if (hex.length != 6) {
    throw FormatException('Expected #rrggbb, got #$hex');
  }
  final alpha = (((color['alpha'] as num?) ?? 1) * 255).round();
  final argb = '${alpha.toRadixString(16).padLeft(2, '0')}$hex';
  return 'Color(0x${argb.toUpperCase()})';
}

/// The number of a W3C dimension, which must be in pixels.
num _pixels(Object? value) {
  final dimension = value! as Map<String, Object?>;
  if (dimension['unit'] != 'px') {
    throw FormatException('Expected px, got ${dimension['unit']}');
  }
  return dimension['value']! as num;
}

String _colorsFile(List<Token> tokens, Map<String, Token> byPath) {
  // theme -> Dart name -> token, e.g. dawn -> textPrimary -> its token
  final themes = <String, Map<String, Token>>{};
  for (final token in tokens.where((token) => token.type == 'color')) {
    final [_, theme, ...name] = token.path;
    themes.putIfAbsent(theme, () => {})[_camelCase(name)] = token;
  }
  final fields = themes.values.first;
  for (final MapEntry(key: theme, value: colors) in themes.entries) {
    if (colors.length != fields.length ||
        !colors.keys.every(fields.containsKey)) {
      throw FormatException('Theme $theme does not have the same colors');
    }
  }

  final out = StringBuffer(_header)
    ..writeln("import 'dart:ui';")
    ..writeln()
    ..writeln('/// The colors of one theme: Dawn (light) or Firefly (dark).')
    ..writeln('final class LmColors {')
    ..writeln('  const new({')
    ..writeAll([for (final name in fields.keys) '    required this.$name,\n'])
    ..writeln('  });')
    ..writeln();

  for (final MapEntry(key: theme, value: colors) in themes.entries) {
    out.writeln('  static const $theme = LmColors(');
    for (final MapEntry(key: name, value: token) in colors.entries) {
      out.writeln('    $name: ${_dartColor(_resolve(token.value, byPath))},');
    }
    out
      ..writeln('  );')
      ..writeln();
  }

  for (final MapEntry(key: name, value: token) in fields.entries) {
    if (token.description != null) {
      out.writeln('  /// ${token.description}');
    }
    out.writeln('  final Color $name;');
  }

  out
    ..writeln()
    ..writeln(
      '  /// The colors between [a] and [b], to animate a theme change.',
    )
    ..writeln('  static LmColors lerp(LmColors a, LmColors b, double t) {')
    ..writeln('    return LmColors(');
  for (final name in fields.keys) {
    out.writeln('      $name: Color.lerp(a.$name, b.$name, t)!,');
  }
  out
    ..writeln('    );')
    ..writeln('  }')
    ..writeln('}');
  return out.toString();
}

String _layoutFile(List<Token> tokens) {
  // group -> its tokens, e.g. space -> [space.1, space.2, …]
  final groups = <String, List<Token>>{};
  for (final token in tokens.where((token) => token.type == 'dimension')) {
    groups.putIfAbsent(token.path.first, () => []).add(token);
  }

  final out = StringBuffer(_header);
  for (final MapEntry(key: group, value: dimensions) in groups.entries) {
    out.writeln('abstract final class Lm${_capitalize(group)} {');
    for (final token in dimensions) {
      var name = _camelCase(token.path.skip(1).toList());
      // A Dart name cannot start with a digit: space.4 becomes s4.
      if (name.startsWith(RegExp('[0-9]'))) {
        name = '${group[0]}$name';
      }
      if (token.description != null) {
        out.writeln('  /// ${token.description}');
      }
      out.writeln('  static const double $name = ${_pixels(token.value)};');
    }
    out
      ..writeln('}')
      ..writeln();
  }
  return out.toString();
}

/// Variable fonts with an optical size axis (`opsz`), and its range. Like
/// Figma, the generator sets it to the font size, so titles get the display
/// cut of the font and small text the text cut.
const Map<String, ({int max, int min})> _opticalSize = {
  'Newsreader': (min: 6, max: 72),
};

String _typographyFile(List<Token> tokens, Map<String, Token> byPath) {
  final out = StringBuffer(_header)
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln('abstract final class LmTypography {');

  for (final token in tokens.where((token) => token.type == 'typography')) {
    final style = token.value! as Map<String, Object?>;
    final name = _camelCase(token.path.skip(1).toList());
    final family = _resolve(style['fontFamily'], byPath)! as String;
    final weight = _resolve(style['fontWeight'], byPath)! as int;
    final size = _pixels(style['fontSize']);
    final opticalSize = _opticalSize[family];

    out
      ..writeln('  static const $name = TextStyle(')
      ..writeln("    fontFamily: '$family',")
      ..writeln("    package: 'lumaely_ui',")
      ..writeln('    fontSize: $size,')
      ..writeln('    height: ${style['lineHeight']},')
      ..writeln('    leadingDistribution: TextLeadingDistribution.even,')
      ..writeln('    letterSpacing: ${_pixels(style['letterSpacing'])},')
      ..writeln('    fontWeight: FontWeight.w$weight,')
      ..writeln('    fontVariations: [')
      ..writeln("      FontVariation('wght', $weight),");
    if (opticalSize != null) {
      final opsz = size.clamp(opticalSize.min, opticalSize.max);
      out.writeln("      FontVariation('opsz', $opsz),");
    }
    out
      ..writeln('    ],')
      ..writeln('  );')
      ..writeln();
  }
  out.writeln('}');
  return out.toString();
}
