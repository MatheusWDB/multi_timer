import 'package:multi_timer/core/services/noop_alarm_scheduler.dart';
import 'package:multi_timer/data/database/app_database.dart';
import 'package:multi_timer/data/repositories/sqlite_preset_repository.dart';
import 'package:multi_timer/data/repositories/sqlite_settings_repository.dart';
import 'package:multi_timer/data/repositories/sqlite_timer_repository.dart';
import 'package:multi_timer/domain/repositories/preset_repository.dart';
import 'package:multi_timer/domain/repositories/settings_repository.dart';
import 'package:multi_timer/domain/repositories/timer_repository.dart';
import 'package:multi_timer/domain/services/alarm_scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dependency_providers.g.dart';

typedef Clock = DateTime Function();

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();

@Riverpod(keepAlive: true)
TimerRepository timerRepository(Ref ref) =>
    SqliteTimerRepository(appDatabase: ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
PresetRepository presetRepository(Ref ref) =>
    SqlitePresetRepository(appDatabase: ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SqliteSettingsRepository(appDatabase: ref.watch(appDatabaseProvider));

// Trocar pela implementação real no item 8.
@Riverpod(keepAlive: true)
AlarmScheduler alarmScheduler(Ref ref) => NoopAlarmScheduler();

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => DateTime.now;
