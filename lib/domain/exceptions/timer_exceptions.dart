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

class TimerNotFoundException implements Exception {
  final String message;

  const TimerNotFoundException(this.message);

  @override
  String toString() => 'TimerNotFoundException: $message';
}

class InvalidTimerStateException implements Exception {
  final String message;

  const InvalidTimerStateException(this.message);

  @override
  String toString() => 'InvalidTimerStateException: $message';
}