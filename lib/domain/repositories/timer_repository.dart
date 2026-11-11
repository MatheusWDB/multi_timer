import 'package:multi_timer/domain/entities/timer.dart';

abstract interface class TimerRepository {
  Future<List<TimerEntity>> getActiveTimers();

  Future<List<TimerEntity>> getHistoryTimers();

  Future<TimerEntity?> getById(int id);

  Future<TimerEntity> insert(TimerEntity timer);

  Future<void> update(TimerEntity timer);

  Future<void> delete(int id);

  Future<void> clearHistory();

  Future<void> deleteHistoryOlderThan(DateTime limit);
}
