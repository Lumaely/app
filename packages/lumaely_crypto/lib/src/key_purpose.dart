/// What a derived key is used for. Each purpose gets its own key.
enum KeyPurpose {
  /// Encrypts the local SQLite database file.
  database('lmy_db__'),
  sync('lmy_sync');

  new(this.context);

  /// libsodium KDF context: exactly 8 characters, unique per purpose.
  final String context;
}
