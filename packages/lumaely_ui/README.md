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

- Mood: `LmMoodCurve` (moment by moment, 2 to 5 columns, empty moments as a
  dashed circle) and `LmMoodSlider` (one mood for the whole day). Both are
  sliders for screen readers and work with the arrow keys.

- Tiles: `LmTile` (rounded `surface` card, any child), `LmTileGroup`
  (optional title, rows in one tile with dividers) and `LmTileRow` (leading,
  title, subtitle, value, chevron when tappable; one button for screen
  readers, value under the title at large text sizes). `LmTileIcon` is the
  small icon box of the settings rows.

## Rules

- Never edit `tokens.json` by hand: change Figma, export again, then run the generator.
