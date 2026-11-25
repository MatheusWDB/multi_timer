import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';

class FakeTimerRepository implements TimerRepository {
  final List<TimerEntity> timers = [];
  int _nextId = 1;

  @override
  Future<List<TimerEntity>> getActiveTimers() async {
    return timers
        .where(
          (timer) =>
              timer.status == TimerStatus.running ||
              timer.status == TimerStatus.paused,
        )
        .toList();
  }

  @override
  Future<TimerEntity?> getById(int id) async {
    for (final timer in timers) {
      if (timer.id == id) return timer;
    }
    return null;
  }

  @override
  Future<TimerEntity> insert(TimerEntity timer) async {
    final inserted = timer.copyWith(id: _nextId++);
    timers.add(inserted);
    return inserted;
  }

  @override
  Future<void> update(TimerEntity timer) async {
    final index = timers.indexWhere((item) => item.id == timer.id);
    if (index == -1) {
      throw StateError('Timer ${timer.id} não existe no repositório fake.');
    }
    timers[index] = timer;
  }

  @override
  Future<void> delete(int id) async {
    timers.removeWhere((timer) => timer.id == id);
  }

  @override
  Future<List<TimerEntity>> getHistoryTimers() async {
    final history = timers
        .where(
          (timer) =>
              timer.status == TimerStatus.finished ||
              timer.status == TimerStatus.stopped,
        )
        .toList();
    history.sort((a, b) => b.finishedAt!.compareTo(a.finishedAt!));
    return history;
  }

  @override
  Future<void> clearHistory() async {
    timers.removeWhere(
      (timer) =>
          timer.status == TimerStatus.finished ||
          timer.status == TimerStatus.stopped,
    );
  }

  @override
  Future<void> deleteHistoryOlderThan(DateTime limit) async {
    timers.removeWhere(
      (timer) =>
          (timer.status == TimerStatus.finished ||
              timer.status == TimerStatus.stopped) &&
          timer.finishedAt!.isBefore(limit),
    );
  }
}
