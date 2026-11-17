import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';
import 'package:multi_timer/domain/services/alarm_scheduler.dart';

class StopTimer {
  final TimerRepository _repository;
  final AlarmScheduler _scheduler;
  final DateTime Function() _now;

  StopTimer({
    required this._repository,
    required this._scheduler,
    required this._now,
  });

  Future<TimerEntity> call({required int timerId}) async {
    final now = _now();
    final TimerEntity? timer = await _repository.getById(timerId);

    if (timer == null) {
      throw TimerNotFoundException('Timer com ID $timerId não encontrado.');
    }

    final TimerEntity stoppedTimer = switch (timer.status) {
      TimerStatus.running => await _timerRunning(timer, now),
      TimerStatus.paused => await _timerPaused(timer, now),
      TimerStatus.finished || TimerStatus.stopped => timer,
    };

    return stoppedTimer;
  }

  Future<TimerEntity> _timerRunning(TimerEntity timer, DateTime now) async {
    final stoppedTimer = timer.copyWith(
      endsAt: () => null,
      status: TimerStatus.stopped,
      finishedAt: () => now,
    );

    await _repository.update(stoppedTimer);
    await _scheduler.cancelAlarm(timer.notificationId);

    return stoppedTimer;
  }

  Future<TimerEntity> _timerPaused(TimerEntity timer, DateTime now) async {
    final stoppedTimer = timer.copyWith(
      status: TimerStatus.stopped,
      finishedAt: () => now,
    );

    await _repository.update(stoppedTimer);

    return stoppedTimer;
  }
}
