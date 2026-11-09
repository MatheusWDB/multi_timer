import 'package:multi_timer/domain/entities/app_theme_mode.dart';

class SettingsEntity {
  final String defaultSoundId;
  final bool vibrate;
  final bool keepScreenOn;
  final AppThemeMode themeMode;
  final int historyRetentionDays;

  const SettingsEntity({
    required this.defaultSoundId,
    required this.vibrate,
    required this.keepScreenOn,
    required this.themeMode,
    required this.historyRetentionDays,
  });

  SettingsEntity copyWith({
    String? defaultSoundId,
    bool? vibrate,
    bool? keepScreenOn,
    AppThemeMode? themeMode,
    int? historyRetentionDays,
  }) {
    return SettingsEntity(
      defaultSoundId: defaultSoundId ?? this.defaultSoundId,
      vibrate: vibrate ?? this.vibrate,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      themeMode: themeMode ?? this.themeMode,
      historyRetentionDays: historyRetentionDays ?? this.historyRetentionDays,
    );
  }

  const SettingsEntity.defaults()
    : defaultSoundId = 'default',
      vibrate = true,
      keepScreenOn = false,
      themeMode = AppThemeMode.system,
      historyRetentionDays = 30;
}
