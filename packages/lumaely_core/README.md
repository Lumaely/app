<img src="../../assets/logo-rounded-256.png" width="48" height="48" alt="Lumaely logo">

# lumaely_core

Lumaely's domain model: days, moods and their rules, in pure Dart.

## Contents

- `LocalDate`: a day as the person lived it, with no time and no time zone.
- `MoodScore` (1 to 5) and `Moment` (morning to night).
- `DayMoods`: either `WholeDayMood` or `MomentMoods`, never both.
- `DayEntry`: what was recorded for one day.
- `EntryRepository`: the contract the data layer implements.
- `Clock`: the current time, injected so tests control it.

## Rules

- No Flutter, no database, no cryptography: this package depends only on
  `meta`, and no other package of the workspace.
- `MoodScore.value` and `Moment.id` are stored in every diary: never change an
  existing one. A golden test freezes the moment ids.

## Tests

```bash
cd packages/lumaely_core && fvm dart test
```
