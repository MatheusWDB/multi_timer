import 'package:multi_timer/domain/services/alarm_scheduler.dart';

class NoopAlarmScheduler implements AlarmScheduler {
  @override
  Future<void> cancelAlarm(int notificationId) async {}

  @override
  Future<void> scheduleAlarm({
    required int notificationId,
    required DateTime endsAt,
  }) async {}
}
