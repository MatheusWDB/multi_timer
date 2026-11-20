import 'package:multi_timer/core/constants/db_constants.dart';
import 'package:multi_timer/domain/entities/preset.dart';

abstract final class PresetMapper {
  static Map<String, Object?> toMap(PresetEntity preset) {
    return {
      if (preset.id != null) DbConstants.colId: preset.id,
      DbConstants.colName: preset.name,
      DbConstants.colSoundId: preset.soundId,
      DbConstants.colColor: preset.color,
      DbConstants.colDurationSeconds: preset.durationSeconds,
      DbConstants.colCreatedAt: preset.createdAt.millisecondsSinceEpoch,
      DbConstants.colPosition: preset.position,
    };
  }

  static PresetEntity fromMap(Map<String, Object?> map) {
    return PresetEntity(
      id: map[DbConstants.colId] as int?,
      name: map[DbConstants.colName] as String,
      soundId: map[DbConstants.colSoundId] as String,
      color: map[DbConstants.colColor] as int,
      durationSeconds: map[DbConstants.colDurationSeconds] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map[DbConstants.colCreatedAt] as int,
      ),
      position: map[DbConstants.colPosition] as int,
    );
  }
}
