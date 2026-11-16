import 'package:multi_timer/core/constants/app_limits.dart';
import 'package:multi_timer/core/utils/time_formatter.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';
import 'package:multi_timer/domain/services/alarm_scheduler.dart';

class StartTimer {
  final TimerRepository _repository;
  final AlarmScheduler _scheduler;
  final DateTime Function() _now;

  StartTimer({
    required this._repository,
    required this._scheduler,
    required this._now,
  });

  Future<TimerEntity> call({
    required int durationSeconds,
    required int color,
    required String soundId,
    String? name,
    int? presetId,
  }) async {
    final minDurationSeconds = AppLimits.minDurationSeconds;
    final maxDurationSeconds = AppLimits.maxDurationSeconds;

    if (durationSeconds < minDurationSeconds ||
        durationSeconds > maxDurationSeconds) {
      throw InvalidDurationException(
        'Duração inválida. Deve ser entre ${TimeFormatter.formatDuration(minDurationSeconds)} e ${TimeFormatter.formatDuration(maxDurationSeconds)}.',
      );
    }

    final maxActiveTimers = AppLimits.maxActiveTimers;
    final activeTimers = await _repository.getActiveTimers();

    if (activeTimers.length >= maxActiveTimers) {
      throw TooManyTimersException(
        'Limite de timers ativos atingido. Máximo permitido: $maxActiveTimers.',
      );
    }

    final trimmed = name?.trim();
    final timerName = trimmed == null || trimmed.isEmpty
        ? 'Timer ${activeTimers.length + 1}'
        : trimmed;

    final now = _now();

    final timer = TimerEntity(
      name: timerName,
      soundId: soundId,
      color: color,
      durationSeconds: durationSeconds,
      remainingSeconds: durationSeconds,
      notificationId: now.millisecondsSinceEpoch % 2147483648,
      createdAt: now,
      status: TimerStatus.running,
      endsAt: now.add(Duration(seconds: durationSeconds)),
      presetId: presetId,
    );

    final insertedTimer = await _repository.insert(timer);

    await _scheduler.scheduleAlarm(
      notificationId: insertedTimer.notificationId,
      endsAt: insertedTimer.endsAt!,
    );

    return insertedTimer;
  }
}
