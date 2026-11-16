<img src="../../assets/logo-rounded-256.png" width="48" height="48" alt="Lumaely logo">

# lumaely_ui

Lumaely's design system: tokens, theme and widgets, in Flutter.

## Contents

- `tokens/tokens.json`: the design tokens exported from Figma (W3C Design Tokens format). The source
  of truth for colors, spacing, radii and text styles.
- `fonts/`: Newsreader and Plus Jakarta Sans, as variable fonts, under the SIL Open Font License
  (see each `OFL.txt`).

- `LmIcons` + `LmIcon`: the icons of the app, Phosphor (regular, MIT) svg
  paths drawn with a `CustomPaint`, the same svg as in the Figma kit. Works
  offline, no font.

## Rules

- Never edit `tokens.json` by hand: change Figma, export again, then run the generator.
