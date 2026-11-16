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
  Future<TimerEntity> insert(TimerEntity timer) async {
    final inserted = timer.copyWith(id: _nextId++);
    timers.add(inserted);
    return inserted;
  }

  @override
  Future<List<TimerEntity>> getHistoryTimers() => throw UnimplementedError();

  @override
  Future<TimerEntity?> getById(int id) => throw UnimplementedError();

  @override
  Future<void> update(TimerEntity timer) => throw UnimplementedError();

  @override
  Future<void> delete(int id) => throw UnimplementedError();

  @override
  Future<void> clearHistory() => throw UnimplementedError();

  @override
  Future<void> deleteHistoryOlderThan(DateTime limit) =>
      throw UnimplementedError();
}
