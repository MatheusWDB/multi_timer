class InvalidDurationException implements Exception {
  final String message;

  const InvalidDurationException(this.message);

  @override
  String toString() => 'InvalidDurationException: $message';
}

class TooManyTimersException implements Exception {
  final String message;

  const TooManyTimersException(this.message);

  @override
  String toString() => 'TooManyTimersException: $message';
}
