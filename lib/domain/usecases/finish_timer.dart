import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';

class FinishTimer {
  final TimerRepository _repository;
  final DateTime Function() _now;

  FinishTimer({required this._repository, required this._now});

  Future<TimerEntity> call({required int timerId}) async {
    final now = _now();
    final TimerEntity? timer = await _repository.getById(timerId);

    if (timer == null) {
      throw TimerNotFoundException('Timer com ID $timerId não encontrado.');
    }

    if (timer.status != TimerStatus.running || timer.endsAt!.isAfter(now)) {
      return timer;
    }

    final finishedTimer = timer.copyWith(
      status: TimerStatus.finished,
      endsAt: () => null,
      finishedAt: () => timer.endsAt!,
    );

    await _repository.update(finishedTimer);

    return finishedTimer;
  }
}
