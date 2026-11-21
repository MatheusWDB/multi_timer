import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/core/constants/db_constants.dart';
import 'package:multi_timer/data/mappers/settings_mapper.dart';
import 'package:multi_timer/domain/entities/app_theme_mode.dart';
import 'package:multi_timer/domain/entities/settings_entity.dart';

void main() {
  const defaults = SettingsEntity.defaults();

  const customSettings = SettingsEntity(
    defaultSoundId: 'bell',
    vibrate: false,
    keepScreenOn: true,
    themeMode: AppThemeMode.dark,
    historyRetentionDays: 45,
  );

  void expectSameSettings(SettingsEntity actual, SettingsEntity expected) {
    expect(actual.defaultSoundId, expected.defaultSoundId);
    expect(actual.vibrate, expected.vibrate);
    expect(actual.keepScreenOn, expected.keepScreenOn);
    expect(actual.themeMode, expected.themeMode);
    expect(actual.historyRetentionDays, expected.historyRetentionDays);
  }

  group('SettingsMapper.toMap', () {
    test('converte todos os campos para texto com as chaves do banco', () {
      final map = SettingsMapper.toMap(customSettings);

      expect(map[DbConstants.keyDefaultSoundId], 'bell');
      expect(map[DbConstants.keyVibrate], 'false');
      expect(map[DbConstants.keyKeepScreenOn], 'true');
      expect(map[DbConstants.keyThemeMode], 'dark');
      expect(map[DbConstants.keyHistoryRetentionDays], '45');
      expect(map, hasLength(5));
    });
  });

  group('SettingsMapper.fromMap', () {
    test('converte um mapa completo em SettingsEntity', () {
      final settings = SettingsMapper.fromMap(<String, String>{
        DbConstants.keyDefaultSoundId: 'chime',
        DbConstants.keyVibrate: 'true',
        DbConstants.keyKeepScreenOn: 'true',
        DbConstants.keyThemeMode: 'light',
        DbConstants.keyHistoryRetentionDays: '90',
      });

      expect(settings.defaultSoundId, 'chime');
      expect(settings.vibrate, isTrue);
      expect(settings.keepScreenOn, isTrue);
      expect(settings.themeMode, AppThemeMode.light);
      expect(settings.historyRetentionDays, 90);
    });

    test('mapa vazio devolve os valores padrão', () {
      final settings = SettingsMapper.fromMap(<String, String>{});

      expectSameSettings(settings, defaults);
    });

    test('chaves ausentes usam o padrão e as presentes são respeitadas', () {
      final settings = SettingsMapper.fromMap(<String, String>{
        DbConstants.keyVibrate: 'false',
      });

      expect(settings.vibrate, isFalse);
      expect(settings.defaultSoundId, defaults.defaultSoundId);
      expect(settings.keepScreenOn, defaults.keepScreenOn);
      expect(settings.themeMode, defaults.themeMode);
      expect(settings.historyRetentionDays, defaults.historyRetentionDays);
    });

    test('retenção com texto inválido usa o padrão', () {
      final settings = SettingsMapper.fromMap(<String, String>{
        DbConstants.keyHistoryRetentionDays: 'abc',
      });

      expect(settings.historyRetentionDays, defaults.historyRetentionDays);
    });

    test('tema desconhecido usa o padrão em vez de lançar erro', () {
      final settings = SettingsMapper.fromMap(<String, String>{
        DbConstants.keyThemeMode: 'neon',
      });

      expect(settings.themeMode, defaults.themeMode);
    });
  });

  group('SettingsMapper - ida e volta', () {
    test('toMap seguido de fromMap preserva as configurações', () {
      final restored = SettingsMapper.fromMap(
        SettingsMapper.toMap(customSettings),
      );

      expectSameSettings(restored, customSettings);
    });

    for (final mode in AppThemeMode.values) {
      test('preserva o tema ${mode.name}', () {
        final original = customSettings.copyWith(themeMode: mode);

        final restored = SettingsMapper.fromMap(SettingsMapper.toMap(original));

        expect(restored.themeMode, mode);
      });
    }
  });
}
