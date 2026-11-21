import 'package:multi_timer/core/constants/db_constants.dart';
import 'package:multi_timer/domain/entities/app_theme_mode.dart';
import 'package:multi_timer/domain/entities/settings_entity.dart';

abstract final class SettingsMapper {
  static Map<String, String> toMap(SettingsEntity settings) {
    return {
      DbConstants.keyDefaultSoundId: settings.defaultSoundId,
      DbConstants.keyVibrate: settings.vibrate.toString(),
      DbConstants.keyKeepScreenOn: settings.keepScreenOn.toString(),
      DbConstants.keyThemeMode: settings.themeMode.name,
      DbConstants.keyHistoryRetentionDays: settings.historyRetentionDays
          .toString(),
    };
  }

  static SettingsEntity fromMap(Map<String, String> map) {
    const defaultSettings = SettingsEntity.defaults();

    return SettingsEntity(
      defaultSoundId:
          map[DbConstants.keyDefaultSoundId] ?? defaultSettings.defaultSoundId,
      vibrate:
          _toBoolOrNull(map[DbConstants.keyVibrate]) ?? defaultSettings.vibrate,
      keepScreenOn:
          _toBoolOrNull(map[DbConstants.keyKeepScreenOn]) ??
          defaultSettings.keepScreenOn,
      themeMode:
          AppThemeMode.values.asNameMap()[map[DbConstants.keyThemeMode]] ??
          defaultSettings.themeMode,
      historyRetentionDays:
          int.tryParse(map[DbConstants.keyHistoryRetentionDays] ?? '') ??
          defaultSettings.historyRetentionDays,
    );
  }

  static bool? _toBoolOrNull(String? value) {
    return value == null ? null : value == 'true';
  }
}
