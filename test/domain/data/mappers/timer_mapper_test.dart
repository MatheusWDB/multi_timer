import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/core/constants/db_constants.dart';
import 'package:multi_timer/data/mappers/timer_mapper.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';

void main() {
  final createdAt = DateTime(2026, 1, 1, 12, 0, 0);
  final ends = DateTime(2026, 1, 1, 12, 5, 0);
  final finished = DateTime(2026, 1, 1, 12, 6, 0);

  TimerEntity buildTimer({
    int? id,
    DateTime? endsAt,
    DateTime? finishedAt,
    int? presetId,
    TimerStatus status = TimerStatus.running,
  }) {
    return TimerEntity(
      id: id,
      name: 'Macarrão',
      soundId: 'default',
      color: 0xFF2196F3,
      durationSeconds: 300,
      remainingSeconds: 120,
      notificationId: 456,
      createdAt: createdAt,
      endsAt: endsAt,
      finishedAt: finishedAt,
      presetId: presetId,
      status: status,
    );
  }

  void expectSameTimer(TimerEntity actual, TimerEntity expected) {
    expect(actual.id, expected.id);
    expect(actual.name, expected.name);
    expect(actual.soundId, expected.soundId);
    expect(actual.color, expected.color);
    expect(actual.durationSeconds, expected.durationSeconds);
    expect(actual.remainingSeconds, expected.remainingSeconds);
    expect(actual.notificationId, expected.notificationId);
    expect(actual.endsAt, expected.endsAt);
    expect(actual.finishedAt, expected.finishedAt);
    expect(actual.createdAt, expected.createdAt);
    expect(actual.presetId, expected.presetId);
    expect(actual.status, expected.status);
  }

  group('TimerMapper.toMap', () {
    test('sem id não inclui a coluna id e converte os tipos', () {
      final map = TimerMapper.toMap(buildTimer(endsAt: ends, presetId: 3));

      expect(map.containsKey(DbConstants.colId), isFalse);
      expect(map[DbConstants.colName], 'Macarrão');
      expect(map[DbConstants.colSoundId], 'default');
      expect(map[DbConstants.colColor], 0xFF2196F3);
      expect(map[DbConstants.colDurationSeconds], 300);
      expect(map[DbConstants.colRemainingSeconds], 120);
      expect(map[DbConstants.colNotificationId], 456);
      expect(map[DbConstants.colPresetId], 3);
      expect(map[DbConstants.colStatus], 'running');
      expect(map[DbConstants.colCreatedAt], createdAt.millisecondsSinceEpoch);
      expect(map[DbConstants.colEndsAt], ends.millisecondsSinceEpoch);
    });

    test('com id inclui a coluna id', () {
      final map = TimerMapper.toMap(buildTimer(id: 7));

      expect(map[DbConstants.colId], 7);
    });

    test('datas e presetId nulos continuam nulos no mapa', () {
      final map = TimerMapper.toMap(buildTimer(status: TimerStatus.paused));

      expect(map[DbConstants.colEndsAt], isNull);
      expect(map[DbConstants.colFinishedAt], isNull);
      expect(map[DbConstants.colPresetId], isNull);
      expect(map[DbConstants.colStatus], 'paused');
    });
  });

  group('TimerMapper.fromMap', () {
    test('converte um registro completo em TimerEntity', () {
      final map = <String, Object?>{
        DbConstants.colId: 9,
        DbConstants.colName: 'Treino',
        DbConstants.colSoundId: 'bell',
        DbConstants.colColor: 0xFFFF0000,
        DbConstants.colDurationSeconds: 60,
        DbConstants.colRemainingSeconds: 60,
        DbConstants.colNotificationId: 11,
        DbConstants.colEndsAt: ends.millisecondsSinceEpoch,
        DbConstants.colFinishedAt: finished.millisecondsSinceEpoch,
        DbConstants.colCreatedAt: createdAt.millisecondsSinceEpoch,
        DbConstants.colPresetId: 2,
        DbConstants.colStatus: 'finished',
      };

      final timer = TimerMapper.fromMap(map);

      expect(timer.id, 9);
      expect(timer.name, 'Treino');
      expect(timer.soundId, 'bell');
      expect(timer.color, 0xFFFF0000);
      expect(timer.durationSeconds, 60);
      expect(timer.remainingSeconds, 60);
      expect(timer.notificationId, 11);
      expect(timer.endsAt, ends);
      expect(timer.finishedAt, finished);
      expect(timer.createdAt, createdAt);
      expect(timer.presetId, 2);
      expect(timer.status, TimerStatus.finished);
    });

    test('campos opcionais nulos viram null na entidade', () {
      final map = TimerMapper.toMap(buildTimer(status: TimerStatus.paused));

      final timer = TimerMapper.fromMap(map);

      expect(timer.id, isNull);
      expect(timer.endsAt, isNull);
      expect(timer.finishedAt, isNull);
      expect(timer.presetId, isNull);
    });

    test('status desconhecido lança ArgumentError', () {
      final map = {
        ...TimerMapper.toMap(buildTimer()),
        DbConstants.colStatus: 'inexistente',
      };

      expect(() => TimerMapper.fromMap(map), throwsArgumentError);
    });
  });

  group('TimerMapper - ida e volta', () {
    for (final status in TimerStatus.values) {
      test('toMap seguido de fromMap preserva o timer ${status.name}', () {
        final isClosed =
            status == TimerStatus.finished || status == TimerStatus.stopped;
        final original = buildTimer(
          id: 5,
          presetId: 3,
          status: status,
          endsAt: status == TimerStatus.running ? ends : null,
          finishedAt: isClosed ? finished : null,
        );

        final restored = TimerMapper.fromMap(TimerMapper.toMap(original));

        expectSameTimer(restored, original);
      });
    }
  });
}
