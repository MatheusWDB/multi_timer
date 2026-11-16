import 'package:multi_timer/domain/services/alarm_scheduler.dart';

class FakeAlarmScheduler implements AlarmScheduler {
  final Map<int, DateTime> scheduled = {};
  final List<int> cancelled = [];

  @override
  Future<void> scheduleAlarm({
    required int notificationId,
    required DateTime endsAt,
  }) async {
    scheduled[notificationId] = endsAt;
  }

  @override
  Future<void> cancelAlarm(int notificationId) async {
    scheduled.remove(notificationId);
    cancelled.add(notificationId);
  }
}
