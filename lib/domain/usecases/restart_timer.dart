import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';
import 'package:multi_timer/domain/services/alarm_scheduler.dart';

class RestartTimer {
  final TimerRepository _repository;
  final AlarmScheduler _scheduler;
  final DateTime Function() _now;

  RestartTimer({
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

    final restartedTimer = switch (timer.status) {
      TimerStatus.running => _timerRunning(timer, now),
      TimerStatus.paused => _timerPaused(timer),
      TimerStatus.finished ||
      TimerStatus.stopped => throw InvalidTimerStateException(
        'Não é possível reiniciar um timer que foi finalizado ou parado.',
      ),
    };

    await _repository.update(restartedTimer);

    if (restartedTimer.status == TimerStatus.running) {
      await _scheduler.scheduleAlarm(
        notificationId: timer.notificationId,
        endsAt: restartedTimer.endsAt!,
      );
    }

    return restartedTimer;
  }

  TimerEntity _timerRunning(TimerEntity timer, DateTime now) {
    final newEndsAt = now.add(Duration(seconds: timer.durationSeconds));

    return timer.copyWith(
      endsAt: () => newEndsAt,
      remainingSeconds: timer.durationSeconds,
    );
  }

  TimerEntity _timerPaused(TimerEntity timer) {
    return timer.copyWith(remainingSeconds: timer.durationSeconds);
  }
}
