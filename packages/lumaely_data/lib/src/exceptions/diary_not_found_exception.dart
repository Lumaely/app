/// Thrown when opening a diary in a folder that holds none.
final class DiaryNotFoundException implements Exception {
  /// Creates the exception.
  const new();

  @override
  String toString() => 'DiaryNotFoundException: no diary in this folder';
}
