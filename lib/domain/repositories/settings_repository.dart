import 'package:multi_timer/domain/entities/settings_entity.dart';

abstract interface class SettingsRepository {
  Future<SettingsEntity> getSettings();

  Future<void> saveSettings(SettingsEntity settings);
}
