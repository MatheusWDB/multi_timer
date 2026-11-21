import 'package:multi_timer/core/constants/db_constants.dart';
import 'package:multi_timer/data/database/app_database.dart';
import 'package:multi_timer/data/mappers/preset_mapper.dart';
import 'package:multi_timer/domain/entities/preset.dart';
import 'package:multi_timer/domain/repositories/preset_repository.dart';

class SqlitePresetRepository implements PresetRepository {
  final AppDatabase _appDatabase;

  SqlitePresetRepository({required this._appDatabase});

  @override
  Future<void> delete(int id) async {
    final db = await _appDatabase.database;

    await db.delete(
      DbConstants.tablePresets,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<PresetEntity>> getAll() async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      DbConstants.tablePresets,
      orderBy: '${DbConstants.colPosition} ASC',
    );

    return rows.map(PresetMapper.fromMap).toList();
  }

  @override
  Future<PresetEntity?> getById(int id) async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      DbConstants.tablePresets,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    return rows.isEmpty ? null : PresetMapper.fromMap(rows.first);
  }

  @override
  Future<PresetEntity> insert(PresetEntity preset) async {
    final db = await _appDatabase.database;

    final id = await db.insert(
      DbConstants.tablePresets,
      PresetMapper.toMap(preset),
    );

    return preset.copyWith(id: id);
  }

  @override
  Future<void> reorder(List<PresetEntity> presets) async {
    final db = await _appDatabase.database;

    await db.transaction((txn) async {
      for (var i = 0; i < presets.length; i++) {
        await txn.update(
          DbConstants.tablePresets,
          {DbConstants.colPosition: i},
          where: '${DbConstants.colId} = ?',
          whereArgs: [presets[i].id],
        );
      }
    });
  }

  @override
  Future<void> update(PresetEntity preset) async {
    final db = await _appDatabase.database;

    final rows = await db.update(
      DbConstants.tablePresets,
      PresetMapper.toMap(preset),
      where: '${DbConstants.colId} = ?',
      whereArgs: [preset.id],
    );

    if (rows == 0) {
      throw StateError('Nenhuma linha alterada ou preset não encontrado');
    }
  }
}
