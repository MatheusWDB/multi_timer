// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dependency_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'98a09c6cfd43966155dfbdb0787fa18c85438e13';

@ProviderFor(timerRepository)
final timerRepositoryProvider = TimerRepositoryProvider._();

final class TimerRepositoryProvider
    extends
        $FunctionalProvider<TimerRepository, TimerRepository, TimerRepository>
    with $Provider<TimerRepository> {
  TimerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timerRepositoryHash();

  @$internal
  @override
  $ProviderElement<TimerRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TimerRepository create(Ref ref) {
    return timerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimerRepository>(value),
    );
  }
}

String _$timerRepositoryHash() => r'eca3856ee2aa23883ec55bf7f26a424a40b7378e';

@ProviderFor(presetRepository)
final presetRepositoryProvider = PresetRepositoryProvider._();

final class PresetRepositoryProvider
    extends
        $FunctionalProvider<
          PresetRepository,
          PresetRepository,
          PresetRepository
        >
    with $Provider<PresetRepository> {
  PresetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presetRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presetRepositoryHash();

  @$internal
  @override
  $ProviderElement<PresetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PresetRepository create(Ref ref) {
    return presetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PresetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PresetRepository>(value),
    );
  }
}

String _$presetRepositoryHash() => r'3512ad656cfedbaa82f7ae33a8356fd927909df5';

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'898f72fecb1919e918ad776c4753866919d0095d';

@ProviderFor(alarmScheduler)
final alarmSchedulerProvider = AlarmSchedulerProvider._();

final class AlarmSchedulerProvider
    extends $FunctionalProvider<AlarmScheduler, AlarmScheduler, AlarmScheduler>
    with $Provider<AlarmScheduler> {
  AlarmSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alarmSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alarmSchedulerHash();

  @$internal
  @override
  $ProviderElement<AlarmScheduler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AlarmScheduler create(Ref ref) {
    return alarmScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AlarmScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AlarmScheduler>(value),
    );
  }
}

String _$alarmSchedulerHash() => r'37748ec771d1b198d32b6b006e2fd15e47c7af72';

@ProviderFor(clock)
final clockProvider = ClockProvider._();

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'ce4c8073e4878f6859ed9a59fae2c1819b4179af';
