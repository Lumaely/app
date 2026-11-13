// lumaely tokens export
//
// builds tokens/tokens.json from the figma variables and local text styles,
// in the W3C design tokens format. see README.md

// one mode per theme (Dawn, Firefly)
const COLOR_COLLECTION = 'v1';
// space/*, radius/*
const LAYOUT_COLLECTION = 'layout';

// font family -> name of its token
const FONT_FAMILIES = { 'Newsreader': 'serif', 'Plus Jakarta Sans': 'sans' };

const FONT_WEIGHTS = {
  thin: 100,
  extralight: 200,
  light: 300,
  regular: 400,
  medium: 500,
  semibold: 600,
  bold: 700,
  extrabold: 800,
  black: 900,
};

const DESCRIPTION =
  'Lumaely design tokens, exported from Figma. Do not edit by hand: change Figma, export again, then run the generator.';

figma.showUI(__html__, { width: 480, height: 420, title: 'Lumaely tokens' });

buildTokens()
  .then((tokens) => figma.ui.postMessage({ json: `${JSON.stringify(tokens, null, 2)}\n` }))
  .catch((error) => figma.ui.postMessage({ error: String(error.message ?? error) }));

async function buildTokens() {
  const collections = await figma.variables.getLocalVariableCollectionsAsync();
  const colors = collections.find((c) => c.name === COLOR_COLLECTION);
  const layout = collections.find((c) => c.name === LAYOUT_COLLECTION);
  if (!colors || !layout) {
    throw new Error(`collections "${COLOR_COLLECTION}" and "${LAYOUT_COLLECTION}" not found`);
  }

  const tokens = { $description: DESCRIPTION };

  // colors: one group per theme
  tokens.color = { $type: 'color' };
  for (const mode of colors.modes) {
    const theme = mode.name.toLowerCase();
    const group = {};

    for (const id of colors.variableIds) {
      const variable = await figma.variables.getVariableByIdAsync(id);
      const value = variable.valuesByMode[mode.modeId];
      const token = {};

      if (value.type === 'VARIABLE_ALIAS') {
        // alias has to point to the same collection
        const target = await figma.variables.getVariableByIdAsync(value.id);
        token.$value = `{color.${theme}.${target.name.split('/').join('.')}}`;
      } else {
        token.$value = color(value);
      }
      if (variable.description) {
        token.$description = variable.description;
      }
      put(group, variable.name.split('/'), token);
    }
    tokens.color[theme] = group;
  }

  // spacing and radii, in px
  for (const id of layout.variableIds) {
    const variable = await figma.variables.getVariableByIdAsync(id);
    const [group, ...name] = variable.name.split('/');
    const token = {
      $value: { value: variable.valuesByMode[layout.modes[0].modeId], unit: 'px' },
    };
    if (variable.description) {
      token.$description = variable.description;
    }
    tokens[group] ??= { $type: 'dimension' };
    put(tokens[group], name, token);
  }

  // text styles
  tokens.fontFamily = { $type: 'fontFamily' };
  tokens.fontWeight = { $type: 'fontWeight' };
  tokens.typography = { $type: 'typography' };

  for (const style of await figma.getLocalTextStylesAsync()) {
    const { family, style: fontStyle } = style.fontName;
    const familyName = FONT_FAMILIES[family] ?? family.toLowerCase().replace(/\s/g, '');
    const weightName = fontStyle.toLowerCase().replace(/\s/g, '');
    if (!(weightName in FONT_WEIGHTS)) {
      throw new Error(`${style.name}: unknown font style "${fontStyle}"`);
    }

    tokens.fontFamily[familyName] = { $value: family };
    tokens.fontWeight[weightName] = { $value: FONT_WEIGHTS[weightName] };

    put(tokens.typography, style.name.split('/'), {
      $value: {
        fontFamily: `{fontFamily.${familyName}}`,
        fontWeight: `{fontWeight.${weightName}}`,
        fontSize: { value: style.fontSize, unit: 'px' },
        lineHeight: lineHeight(style),
        letterSpacing: { value: letterSpacing(style), unit: 'px' },
      },
    });
  }
  tokens.fontWeight = sortWeights(tokens.fontWeight);

  return tokens;
}

// W3C color + hex (easier to read, and it's what the generator uses)
function color({ r, g, b, a }) {
  const hex = [r, g, b].map((c) => Math.round(c * 255).toString(16).padStart(2, '0')).join('');
  return {
    colorSpace: 'srgb',
    components: [r, g, b].map((c) => round(c, 4)),
    alpha: round(a, 4),
    hex: `#${hex}`,
  };
}

// W3C wants a ratio of the font size (same as TextStyle.height in flutter)
function lineHeight(style) {
  const { unit, value } = style.lineHeight;
  if (unit === 'PIXELS') return round(value / style.fontSize, 4);
  if (unit === 'PERCENT') return round(value / 100, 4);
  throw new Error(`${style.name}: set a line height (not auto)`);
}

function letterSpacing(style) {
  const { unit, value } = style.letterSpacing;
  if (unit === 'PERCENT') return round((value / 100) * style.fontSize, 2);
  return round(value, 2);
}

// regular, medium, semibold... instead of the order they appear in
function sortWeights(weights) {
  const { $type, ...rest } = weights;
  const sorted = Object.entries(rest).sort(([, a], [, b]) => a.$value - b.$value);
  return { $type, ...Object.fromEntries(sorted) };
}

// put(tree, ['text', 'primary'], token) -> tree.text.primary = token
function put(tree, path, token) {
  let node = tree;
  for (const key of path.slice(0, -1)) {
    node[key] ??= {};
    node = node[key];
  }
  node[path[path.length - 1]] = token;
}

function round(value, digits) {
  const factor = 10 ** digits;
  return Math.round(value * factor) / factor;
}
