import 'package:multi_timer/domain/entities/settings_entity.dart';
import 'package:multi_timer/presentation/providers/dependency_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  Future<SettingsEntity> build() async {
    return await ref.read(settingsRepositoryProvider).getSettings();
  }

  Future<void> save(SettingsEntity settings) async {
    await ref.read(settingsRepositoryProvider).saveSettings(settings);
    state = AsyncData(settings);
  }
}
