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

- Days: `LmMoodDot` (round mood mark: a score, an average in a blended
  color, or a dashed circle when empty) and `LmDayRow` (one day in a list:
  dot, date, mood line like `3.5/5 · Good · 4 moments`, first line of the
  journal; read in full words by screen readers).

- Sheets and dialogs: `showLmSheet` + `LmSheet` (title, message, content,
  full width actions; scrolls, stays above the keyboard) for most things,
  `showLmDialog` + `LmDialog` only to confirm something that can't be
  undone. Their look (surface raised, radii `sheet` / `dialog`, drag
  handle) comes from the theme.

- Calendar: `LmMonthCalendar` (one month, weeks from monday, entries in,
  `onDayTap` out; future days can't be tapped) built from `LmCalendarDay`
  (mood dot, date under it, journal mark, ring on today) and
  `LmCalendarLegend` (in a sheet, opened by `LmCalendarLegendButton`, the
  "?" that the journal screen puts once in its top bar). `LmWeekStrip` is
  one week of it for Today (letters above, no journal mark);
  `LmWeekdayLetters` is the "M T W T F S S" row they share.

- Chart: `LmMoodChart` (mood over a period on a fixed 1 to 5 axis, 5 grid
  lines; the line is cut where nothing was written; per day, 7 day rolling
  average, per week or per month; read as a summary by screen readers).

## Rules

- Never edit `tokens.json` by hand: change Figma, export again, then run the generator.
