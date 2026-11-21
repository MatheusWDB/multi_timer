import 'package:multi_timer/core/constants/db_constants.dart';
import 'package:multi_timer/data/database/app_database.dart';
import 'package:multi_timer/data/mappers/settings_mapper.dart';
import 'package:multi_timer/domain/entities/settings_entity.dart';
import 'package:multi_timer/domain/repositories/settings_repository.dart';
import 'package:sqflite/sqflite.dart';

class SqliteSettingsRepository implements SettingsRepository {
  final AppDatabase _appDatabase;

  SqliteSettingsRepository({required this._appDatabase});

  @override
  Future<SettingsEntity> getSettings() async {
    final db = await _appDatabase.database;

    final rows = await db.query(DbConstants.tableSettings);

    final Map<String, String> settings = {
      for (final row in rows)
        row[DbConstants.colSettingKey] as String:
            (row[DbConstants.colSettingValue] as String),
    };

    return SettingsMapper.fromMap(settings);
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    final db = await _appDatabase.database;

    final values = SettingsMapper.toMap(settings);

    await db.transaction((txn) async {
      for (final entry in values.entries) {
        await txn.insert(DbConstants.tableSettings, {
          DbConstants.colSettingKey: entry.key,
          DbConstants.colSettingValue: entry.value,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
