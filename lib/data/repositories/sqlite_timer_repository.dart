import 'package:multi_timer/core/constants/db_constants.dart';
import 'package:multi_timer/data/database/app_database.dart';
import 'package:multi_timer/data/mappers/timer_mapper.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';

class SqliteTimerRepository implements TimerRepository {
  final AppDatabase _appDatabase;

  SqliteTimerRepository({required this._appDatabase});

  @override
  Future<void> clearHistory() async {
    final db = await _appDatabase.database;

    await db.delete(
      DbConstants.tableTimers,
      where: '${DbConstants.colStatus} IN (?, ?)',
      whereArgs: [TimerStatus.finished.name, TimerStatus.stopped.name],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _appDatabase.database;

    await db.delete(
      DbConstants.tableTimers,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteHistoryOlderThan(DateTime limit) async {
    final db = await _appDatabase.database;

    await db.delete(
      DbConstants.tableTimers,
      where:
          '${DbConstants.colStatus} IN (?, ?) AND ${DbConstants.colFinishedAt} < ?',
      whereArgs: [
        TimerStatus.finished.name,
        TimerStatus.stopped.name,
        limit.millisecondsSinceEpoch,
      ],
    );
  }

  @override
  Future<List<TimerEntity>> getActiveTimers() async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      DbConstants.tableTimers,
      where: '${DbConstants.colStatus} IN (?, ?)',
      whereArgs: [TimerStatus.running.name, TimerStatus.paused.name],
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );

    return rows.map(TimerMapper.fromMap).toList();
  }

  @override
  Future<TimerEntity?> getById(int id) async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      DbConstants.tableTimers,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    return rows.isEmpty ? null : TimerMapper.fromMap(rows.first);
  }

  @override
  Future<List<TimerEntity>> getHistoryTimers() async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      DbConstants.tableTimers,
      where: '${DbConstants.colStatus} IN (?, ?)',
      whereArgs: [TimerStatus.finished.name, TimerStatus.stopped.name],
      orderBy: '${DbConstants.colFinishedAt} DESC',
    );

    return rows.map(TimerMapper.fromMap).toList();
  }

  @override
  Future<TimerEntity> insert(TimerEntity timer) async {
    final db = await _appDatabase.database;

    final id = await db.insert(
      DbConstants.tableTimers,
      TimerMapper.toMap(timer),
    );

    return timer.copyWith(id: id);
  }

  @override
  Future<void> update(TimerEntity timer) async {
    final db = await _appDatabase.database;

    final rows = await db.update(
      DbConstants.tableTimers,
      TimerMapper.toMap(timer),
      where: '${DbConstants.colId} = ?',
      whereArgs: [timer.id],
    );

    if (rows == 0) {
      throw StateError('Nenhuma linha alterada ou timer não encontrado');
    }
  }
}
