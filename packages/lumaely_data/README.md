<img src="../../assets/logo-rounded-256.png" width="48" height="48" alt="Lumaely logo">

# lumaely_data

Where Lumaely's diary lives: the encrypted database and the code that reads and
writes it.

## Contents

- `AppDatabase`: drift on SQLite3 Multiple Ciphers. Tables `entries`,
  `entry_moods`, `change_log` and `database_meta`.
- `LocalDiary`: creates, opens and closes a diary (`diary.db` and
  `diary.lmkey`), and gives access to its entries.
- `MasterKeyCache`: the contract for the device's key storage, implemented by
  the app.
- The entry repository, reached through `LocalDiary.entries`.

## Rules

- Every write runs in one transaction that also records the change in
  `change_log`, for the future sync engine.
- Only rows whose content changed are rewritten.
- Nothing is erased: a deletion marks rows with `deleted_at` and wipes the
  journal text.
- Record id labels (`entry:…`, `mood:…`) are stored formats: a golden test
  freezes them.

## Tests

Generated code is not committed. Generate it, then run the tests from this
folder so the native build hooks run:

```bash
cd packages/lumaely_data
fvm dart run build_runner build
fvm dart test
```
