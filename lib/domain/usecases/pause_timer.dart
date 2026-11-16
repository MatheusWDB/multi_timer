import 'dart:math';

import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';
import 'package:multi_timer/domain/services/alarm_scheduler.dart';

class PauseTimer {
  final TimerRepository _repository;
  final AlarmScheduler _scheduler;
  final DateTime Function() _now;

  PauseTimer({
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

    if (timer.status != TimerStatus.running) {
      throw InvalidTimerStateException(
        'Não é possível pausar um timer que não está em execução.',
      );
    }

    final remainingMillis = timer.endsAt!.difference(now).inMilliseconds;
    final remainingSeconds = max(1, (remainingMillis / 1000).ceil());

    final updatedTimer = timer.copyWith(
      remainingSeconds: remainingSeconds,
      endsAt: () => null,
      status: TimerStatus.paused,
    );

    await _repository.update(updatedTimer);
    await _scheduler.cancelAlarm(timer.notificationId);
    return updatedTimer;
  }
}
