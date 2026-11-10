<img src="../../assets/logo-rounded-256.png" width="48" height="48" alt="Lumaely logo">

# lumaely_crypto

Lumaely's cryptography, built on libsodium through the `sodium` package.

## Contents

- `LmCryptoEngine`:
  - creates the master key, and derives one key per `KeyPurpose` from it;
  - locks the master key with a password (Argon2id, then
    XChaCha20-Poly1305), on a background isolate so the UI stays smooth;
  - locks it with a recovery key, and computes record ids (HMAC).
- `RecoveryKey`: 24 words with a checksum, in the BIP-39 format.
- `KeyFile`: the `diary.lmkey` format, which holds both locks and never the
  master key itself.

## Rules

- No Flutter and no other package of the workspace.
- Never change an existing `KeyPurpose` context: the key it derives, and
  everything that key protects, would change with it. A golden test freezes
  them.
- No cryptographic primitive is written here: libsodium provides them all.

## Tests

Run them from this folder, so the native build hook compiles libsodium:

```bash
cd packages/lumaely_crypto && fvm dart test
```
