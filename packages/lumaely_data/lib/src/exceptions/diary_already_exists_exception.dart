/// Thrown when creating a diary in a folder that already holds one.
final class DiaryAlreadyExistsException implements Exception {
  /// Creates the exception.
  const new();

  @override
  String toString() =>
      'DiaryAlreadyExistsException: a diary already exists in this folder';
}
