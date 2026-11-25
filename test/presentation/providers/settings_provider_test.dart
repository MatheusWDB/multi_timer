import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/data/database/app_database.dart';
import 'package:multi_timer/domain/entities/app_theme_mode.dart';
import 'package:multi_timer/domain/entities/settings_entity.dart';
import 'package:multi_timer/presentation/providers/dependency_providers.dart';
import 'package:multi_timer/presentation/providers/settings_provider.dart';
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
  late ProviderContainer container;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    appDatabase = AppDatabase(path: inMemoryDatabasePath);
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(appDatabase)],
    );
    addTearDown(container.dispose);
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

  group('build', () {
    test('banco vazio devolve as configurações padrão', () async {
      final settings = await container.read(settingsProvider.future);

      expectSameSettings(settings, defaults);
    });
  });

  group('save', () {
    test('atualiza o estado e grava no banco', () async {
      await container.read(settingsProvider.future);

      await container.read(settingsProvider.notifier).save(customSettings);

      expectSameSettings(
        container.read(settingsProvider).requireValue,
        customSettings,
      );

      final saved = await container
          .read(settingsRepositoryProvider)
          .getSettings();
      expectSameSettings(saved, customSettings);
    });
  });
}
