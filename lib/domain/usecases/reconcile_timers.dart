import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';
import 'package:multi_timer/domain/services/alarm_scheduler.dart';
import 'package:multi_timer/domain/usecases/finish_timer.dart';

class ReconcileTimers {
  final TimerRepository _repository;
  final AlarmScheduler _scheduler;
  final DateTime Function() _now;
  final FinishTimer _finishTimer;

  ReconcileTimers({
    required this._repository,
    required this._scheduler,
    required this._now,
    required this._finishTimer,
  });

  Future<List<TimerEntity>> call() async {
    final now = _now();
    final List<TimerEntity> activeTimers = await _repository.getActiveTimers();

    final List<TimerEntity> finishedTimers = [];

    for (final timer in activeTimers) {
      if (timer.status == TimerStatus.paused) continue;

      if (timer.status == TimerStatus.running && !timer.endsAt!.isAfter(now)) {
        final finishedTimer = await _finishTimer(timerId: timer.id!);
        finishedTimers.add(finishedTimer);
      } else {
        await _scheduler.scheduleAlarm(
          notificationId: timer.notificationId,
          endsAt: timer.endsAt!,
        );
      }
    }

    return finishedTimers;
  }
}
