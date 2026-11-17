import 'package:multi_timer/core/constants/app_limits.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';
import 'package:multi_timer/domain/services/alarm_scheduler.dart';

class AddMinute {
  final TimerRepository _repository;
  final AlarmScheduler _scheduler;
  final DateTime Function() _now;

  AddMinute({
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

    final TimerEntity updatedTimer = switch (timer.status) {
      TimerStatus.running => _timerRunning(timer, now),
      TimerStatus.paused => _timerPaused(timer),
      TimerStatus.finished => await _timerFinished(timer, now),
      TimerStatus.stopped => throw InvalidTimerStateException(
        'Não é possível adicionar um minuto a um timer que foi parado.',
      ),
    };

    await _repository.update(updatedTimer);

    if (updatedTimer.status == TimerStatus.running) {
      await _scheduler.scheduleAlarm(
        notificationId: timer.notificationId,
        endsAt: updatedTimer.endsAt!,
      );
    }

    return updatedTimer;
  }

  TimerEntity _timerRunning(TimerEntity timer, DateTime now) {
    final base = timer.endsAt!.isAfter(now) ? timer.endsAt! : now;

    final newEndsAt = base.add(Duration(seconds: AppLimits.addTimeSeconds));

    if (newEndsAt.difference(now) >
        Duration(seconds: AppLimits.maxDurationSeconds)) {
      throw InvalidDurationException(
        'Não é possível adicionar mais tempo a este timer, pois ele atingiu o limite máximo de duração.',
      );
    }

    return timer.copyWith(endsAt: () => newEndsAt);
  }

  TimerEntity _timerPaused(TimerEntity timer) {
    if (timer.remainingSeconds + AppLimits.addTimeSeconds >
        AppLimits.maxDurationSeconds) {
      throw InvalidDurationException(
        'Não é possível adicionar mais tempo a este timer, pois ele atingiu o limite máximo de duração.',
      );
    }

    final newRemainingSeconds =
        timer.remainingSeconds + AppLimits.addTimeSeconds;
    return timer.copyWith(remainingSeconds: newRemainingSeconds);
  }

  Future<TimerEntity> _timerFinished(TimerEntity timer, DateTime now) async {
    final activeTimers = await _repository.getActiveTimers();
    if (activeTimers.length >= AppLimits.maxActiveTimers) {
      throw TooManyTimersException(
        'Não é possível adicionar mais tempo a este timer, pois o número máximo de timers ativos foi atingido.',
      );
    }
    final newEndsAt = now.add(Duration(seconds: AppLimits.addTimeSeconds));

    return timer.copyWith(
      endsAt: () => newEndsAt,
      remainingSeconds: AppLimits.addTimeSeconds,
      status: TimerStatus.running,
      finishedAt: () => null,
    );
  }
}
