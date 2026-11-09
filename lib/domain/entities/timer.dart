import 'package:multi_timer/domain/entities/timer_status.dart';

class TimerEntity {
  final int? id;
  final String name;
  final String soundId;
  final int color;
  final int durationSeconds;
  final int remainingSeconds;
  final int notificationId;
  final DateTime? endsAt;
  final DateTime? finishedAt;
  final DateTime createdAt;
  final int? presetId;
  final TimerStatus status;

  const TimerEntity({
    this.id,
    required this.name,
    required this.soundId,
    required this.color,
    required this.durationSeconds,
    required this.remainingSeconds,
    required this.notificationId,
    this.endsAt,
    this.finishedAt,
    required this.createdAt,
    this.presetId,
    required this.status,
  });

  TimerEntity copyWith({
    int? id,
    int? remainingSeconds,
    DateTime? Function()? endsAt,
    DateTime? Function()? finishedAt,
    TimerStatus? status,
  }) {
    return TimerEntity(
      id: id ?? this.id,
      name: name,
      soundId: soundId,
      color: color,
      durationSeconds: durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      notificationId: notificationId,
      endsAt: endsAt != null ? endsAt() : this.endsAt,
      finishedAt: finishedAt != null ? finishedAt() : this.finishedAt,
      createdAt: createdAt,
      presetId: presetId,
      status: status ?? this.status,
    );
  }
}
