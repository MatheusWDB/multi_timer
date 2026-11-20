import 'package:multi_timer/core/constants/db_constants.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';

abstract final class TimerMapper {
  static Map<String, Object?> toMap(TimerEntity timer) {
    return {
      if (timer.id != null) DbConstants.colId: timer.id,
      DbConstants.colName: timer.name,
      DbConstants.colSoundId: timer.soundId,
      DbConstants.colColor: timer.color,
      DbConstants.colDurationSeconds: timer.durationSeconds,
      DbConstants.colRemainingSeconds: timer.remainingSeconds,
      DbConstants.colNotificationId: timer.notificationId,
      DbConstants.colEndsAt: timer.endsAt?.millisecondsSinceEpoch,
      DbConstants.colFinishedAt: timer.finishedAt?.millisecondsSinceEpoch,
      DbConstants.colCreatedAt: timer.createdAt.millisecondsSinceEpoch,
      DbConstants.colPresetId: timer.presetId,
      DbConstants.colStatus: timer.status.name,
    };
  }

  static TimerEntity fromMap(Map<String, Object?> map) {
    return TimerEntity(
      id: map[DbConstants.colId] as int?,
      name: map[DbConstants.colName] as String,
      soundId: map[DbConstants.colSoundId] as String,
      color: map[DbConstants.colColor] as int,
      durationSeconds: map[DbConstants.colDurationSeconds] as int,
      remainingSeconds: map[DbConstants.colRemainingSeconds] as int,
      notificationId: map[DbConstants.colNotificationId] as int,
      endsAt: _toDateTimeOrNull(map[DbConstants.colEndsAt]),
      finishedAt: _toDateTimeOrNull(map[DbConstants.colFinishedAt]),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map[DbConstants.colCreatedAt] as int,
      ),
      presetId: map[DbConstants.colPresetId] as int?,
      status: TimerStatus.values.byName(map[DbConstants.colStatus] as String),
    );
  }

  static DateTime? _toDateTimeOrNull(Object? value) {
    return value == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(value as int);
  }
}
