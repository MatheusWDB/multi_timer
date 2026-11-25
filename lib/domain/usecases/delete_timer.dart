import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';
import 'package:multi_timer/domain/services/alarm_scheduler.dart';

class DeleteTimer {
  final TimerRepository _repository;
  final AlarmScheduler _scheduler;

  DeleteTimer({required this._repository, required this._scheduler});

  Future<void> call({required int timerId}) async {
    final TimerEntity? timer = await _repository.getById(timerId);

    if (timer == null) {
      throw TimerNotFoundException('Timer com ID $timerId não encontrado.');
    }

    if (timer.status == TimerStatus.running) {
      await _scheduler.cancelAlarm(timer.notificationId);
    }

    await _repository.delete(timer.id!);
  }
}
