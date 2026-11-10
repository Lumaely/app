<p align="center">
  <img src="assets/logo-rounded-256.png" width="112" height="112" alt="Lumaely logo">
</p>

<h1 align="center">Lumaely</h1>

<p align="center">
  A private mood diary for iPhone and Android: end-to-end encrypted, local-first.
</p>

<p align="center">
  <a href="https://github.com/Lumaely/app/actions/workflows/ci.yml"><img src="https://github.com/Lumaely/app/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI status"></a>
</p>

> [!NOTE]
> Lumaely is in early development (v0.1-alpha). Things are prone to change.

## What it is

Lumaely records how each day went: one mood for the whole day or one per moment, plus a few words of
journal. Everything stays on the phone, encrypted. A synchronization service, built separately,
will come later and will only ever see encrypted data.

## Privacy by design

- **Encrypted at rest.** The diary is an SQLite database encrypted with SQLite3 Multiple Ciphers,
  under a key derived from a random master key.
- **Two ways in, nothing in clear.** The master key is locked by the diary password (Argon2id,
  XChaCha20-Poly1305) and by a 24-word recovery key.
- **Opens without typing the password every time.** The master key is cached in the iOS Keychain or
  the Android Keystore.
- **Ids that reveal nothing.** Records tied to a date get a keyed hash as id, so a sync server
  cannot tell which days were written.

Found a vulnerability? Please read [SECURITY.md](SECURITY.md) and report it privately.

## Repository

| Folder                                                | Contents                                                  |
|-------------------------------------------------------|-----------------------------------------------------------|
| [`app/`](app)                                         | The Flutter app: startup, state, screens                  |
| [`packages/lumaely_core/`](packages/lumaely_core)     | Domain model: days, moods and their rules                 |
| [`packages/lumaely_crypto/`](packages/lumaely_crypto) | Keys, password and recovery locks, record ids (libsodium) |
| [`packages/lumaely_data/`](packages/lumaely_data)     | Encrypted database, diary lifecycle, repositories         |

It is a Dart pub workspace. Dependencies only point one way:
`app` → `lumaely_data` → `lumaely_crypto` and `lumaely_core`, which depend on no other package of
the workspace.

## Getting started

You need [FVM](https://fvm.app), plus Xcode for iOS or Android Studio for Android.

```bash
fvm install                          # the Flutter version pinned in .fvmrc
fvm flutter pub get
git config core.hooksPath .githooks  # formats Dart files before each commit

(cd packages/lumaely_data && fvm dart run build_runner build)
(cd app && fvm dart run build_runner build)

cd app && fvm flutter run
```

## Development

- **Tests** run from each package folder, so the native build hooks (libsodium, sqlite3mc) run too:
  `cd packages/lumaely_crypto && fvm dart test`, and `fvm flutter test` in `app/`.
- **CI** checks formatting, runs the analyzer (where infos fail the build) and every test suite on
  each pull request.
- **Stored values never change.** Moment ids, key derivation contexts and record id labels are
  written in every diary. Changing one breaks existing diaries, so golden tests freeze them: never
  update a golden value to make a test pass.
