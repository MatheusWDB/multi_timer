import 'package:multi_timer/domain/entities/preset.dart';

abstract interface class PresetRepository {
  Future<List<PresetEntity>> getAll();

  Future<PresetEntity?> getById(int id);

  Future<PresetEntity> insert(PresetEntity preset);

  Future<void> update(PresetEntity preset);

  Future<void> delete(int id);

  Future<void> reorder(List<PresetEntity> presets);
}