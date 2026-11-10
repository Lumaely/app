<p align="center">
  <img src="assets/logo-rounded-256.png" width="72" height="72" alt="Lumaely logo">
</p>

# Security policy

Lumaely is a diary: what people write in it is among the most private data they
have. Every security report is taken seriously.

## Reporting a vulnerability

**Please do not open a public issue.** Report it privately instead:
[open a private security advisory](https://github.com/Lumaely/app/security/advisories/new)
(Security tab → *Report a vulnerability*).

Please include:

- what the vulnerability is, and what an attacker could do with it;
- the steps to reproduce it, or a proof of concept;
- the app version or commit, and the device and OS.

Never include real diary content, real passwords or real recovery keys: create
a test diary instead.

We aim to acknowledge a report within 7 days and to keep you informed until a
fix ships. Please give us reasonable time to fix the issue before disclosing it
publicly.

## Supported versions

Lumaely is not released yet: only the latest commit of `main` receives security
fixes.

## Scope

In scope, this repository:

- generation, derivation, caching and wiping of keys;
- encryption of the diary at rest, password and recovery locks;
- the key file (`diary.lmkey`) format and its parsing;
- anything that could expose diary content: logs, clipboard, crash reports,
  screenshots, backups.

Out of scope:

- the sync server, which lives in another repository;
- attacks that need a jailbroken or rooted device, or malware already running
  on it;
- someone who holds the unlocked phone itself: in v0.1 the diary opens without
  a password once its key is in the Keychain or Keystore. An app lock is
  planned.

## Security model, in short

| What | How |
|---|---|
| Master key | 32 random bytes, generated on the device |
| Diary at rest | SQLite3 Multiple Ciphers, with a key derived from the master key |
| Password lock | Argon2id (3 passes, 64 MiB), then XChaCha20-Poly1305 |
| Recovery lock | 24-word recovery key (256 bits), then XChaCha20-Poly1305 |
| Key on the device | iOS Keychain or Android Keystore, this device only |
| Record ids | HMAC of a label such as `entry:2026-10-29`, under a derived key |

All primitives come from libsodium; none is written in this repository.
