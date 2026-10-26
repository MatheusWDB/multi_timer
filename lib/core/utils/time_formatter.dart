abstract final class TimeFormatter {
  static String formatDuration(int seconds) {
    final int hours = seconds ~/ 3600;
    final String minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final String remainingSeconds = (seconds % 60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$remainingSeconds';
    }

    return '$minutes:$remainingSeconds';
  }

  static int toTotalSeconds({int hours = 0, int minutes = 0, int seconds = 0}) {
    return (hours * 3600) + (minutes * 60) + seconds;
  }
}
