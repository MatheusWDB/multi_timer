abstract interface class AlarmScheduler {
  Future<void> scheduleAlarm({
    required int notificationId,
    required DateTime endsAt,
  });

  Future<void> cancelAlarm(int notificationId);
}
