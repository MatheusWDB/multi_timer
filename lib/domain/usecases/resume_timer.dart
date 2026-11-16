import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';
import 'package:multi_timer/domain/services/alarm_scheduler.dart';

class ResumeTimer {
  final TimerRepository _repository;
  final AlarmScheduler _scheduler;
  final DateTime Function() _now;

  ResumeTimer({
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

    if (timer.status != TimerStatus.paused) {
      throw InvalidTimerStateException(
        'Não é possível retomar um timer que não está pausado.',
      );
    }

    final endsAt = now.add(Duration(seconds: timer.remainingSeconds));

    final updatedTimer = timer.copyWith(
      endsAt: () => endsAt,
      status: TimerStatus.running,
    );

    await _repository.update(updatedTimer);
    await _scheduler.scheduleAlarm(
      notificationId: updatedTimer.notificationId,
      endsAt: endsAt,
    );
    return updatedTimer;
  }
}
