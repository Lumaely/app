/// Thrown when the database file can't be read with the given key.
final class WrongDatabaseKeyException implements Exception {
  /// Creates the exception.
  const new();

  @override
  String toString() =>
      'WrongDatabaseKeyException: the key does not open this database';
}
