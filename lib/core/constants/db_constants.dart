abstract final class DbConstants {
  static const String dbName = 'multi_timer.db';
  static const int dbVersion = 1;

  static const String tableTimers = 'timers';
  static const String tablePresets = 'presets';
  static const String tableSettings = 'settings';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colColor = 'color';
  static const String colSoundId = 'sound_id';
  static const String colDurationSeconds = 'duration_seconds';
  static const String colCreatedAt = 'created_at';

  static const String colRemainingSeconds = 'remaining_seconds';
  static const String colEndsAt = 'ends_at';
  static const String colStatus = 'status';
  static const String colNotificationId = 'notification_id';
  static const String colPresetId = 'preset_id';
  static const String colFinishedAt = 'finished_at';

  static const String colPosition = 'position';

  static const String colSettingKey = 'setting_key';
  static const String colSettingValue = 'setting_value';

  static const String keyDefaultSoundId = 'default_sound_id';
  static const String keyVibrate = 'vibrate';
  static const String keyKeepScreenOn = 'keep_screen_on';
  static const String keyThemeMode = 'theme_mode';
  static const String keyHistoryRetentionDays = 'history_retention_days';
}
