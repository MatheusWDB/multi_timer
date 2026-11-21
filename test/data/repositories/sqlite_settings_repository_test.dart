import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/core/constants/db_constants.dart';
import 'package:multi_timer/data/database/app_database.dart';
import 'package:multi_timer/data/repositories/sqlite_settings_repository.dart';
import 'package:multi_timer/domain/entities/app_theme_mode.dart';
import 'package:multi_timer/domain/entities/settings_entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  const defaults = SettingsEntity.defaults();

  const customSettings = SettingsEntity(
    defaultSoundId: 'bell',
    vibrate: false,
    keepScreenOn: true,
    themeMode: AppThemeMode.dark,
    historyRetentionDays: 45,
  );

  late AppDatabase appDatabase;
  late SqliteSettingsRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    appDatabase = AppDatabase(path: inMemoryDatabasePath);
    repository = SqliteSettingsRepository(appDatabase: appDatabase);
  });

  tearDown(() async {
    final db = await appDatabase.database;
    await db.close();
  });

  void expectSameSettings(SettingsEntity actual, SettingsEntity expected) {
    expect(actual.defaultSoundId, expected.defaultSoundId);
    expect(actual.vibrate, expected.vibrate);
    expect(actual.keepScreenOn, expected.keepScreenOn);
    expect(actual.themeMode, expected.themeMode);
    expect(actual.historyRetentionDays, expected.historyRetentionDays);
  }

  Future<void> insertRawSetting(String key, String value) async {
    final db = await appDatabase.database;
    await db.insert(DbConstants.tableSettings, {
      DbConstants.colSettingKey: key,
      DbConstants.colSettingValue: value,
    });
  }

  group('getSettings', () {
    test('banco vazio devolve os valores padrão', () async {
      final settings = await repository.getSettings();

      expectSameSettings(settings, defaults);
    });

    test('configuração parcial usa o padrão nas chaves ausentes', () async {
      await insertRawSetting(DbConstants.keyVibrate, 'false');

      final settings = await repository.getSettings();

      expect(settings.vibrate, isFalse);
      expect(settings.defaultSoundId, defaults.defaultSoundId);
      expect(settings.keepScreenOn, defaults.keepScreenOn);
      expect(settings.themeMode, defaults.themeMode);
      expect(settings.historyRetentionDays, defaults.historyRetentionDays);
    });

    test('valor corrompido no banco usa o padrão em vez de quebrar', () async {
      await insertRawSetting(DbConstants.keyThemeMode, 'neon');
      await insertRawSetting(DbConstants.keyHistoryRetentionDays, 'abc');

      final settings = await repository.getSettings();

      expect(settings.themeMode, defaults.themeMode);
      expect(settings.historyRetentionDays, defaults.historyRetentionDays);
    });
  });

  group('saveSettings', () {
    test('o que foi salvo é devolvido pelo getSettings', () async {
      await repository.saveSettings(customSettings);

      final settings = await repository.getSettings();

      expectSameSettings(settings, customSettings);
    });

    test('salvar de novo substitui os valores sem duplicar linhas', () async {
      await repository.saveSettings(customSettings);
      await repository.saveSettings(
        customSettings.copyWith(themeMode: AppThemeMode.light, vibrate: true),
      );

      final settings = await repository.getSettings();
      expect(settings.themeMode, AppThemeMode.light);
      expect(settings.vibrate, isTrue);
      expect(settings.defaultSoundId, 'bell');

      final db = await appDatabase.database;
      final rows = await db.query(DbConstants.tableSettings);
      expect(rows, hasLength(5));
    });
  });
}
