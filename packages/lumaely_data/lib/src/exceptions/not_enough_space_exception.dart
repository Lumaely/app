/// Thrown when the phone has no space left to write the diary.
final class NotEnoughSpaceException implements Exception {
  /// Creates the exception.
  const new();

  @override
  String toString() => 'NotEnoughSpaceException: no space left on the device';
}
