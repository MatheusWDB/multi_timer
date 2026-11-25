// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_timers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveTimers)
final activeTimersProvider = ActiveTimersProvider._();

final class ActiveTimersProvider
    extends $AsyncNotifierProvider<ActiveTimers, List<TimerEntity>> {
  ActiveTimersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeTimersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeTimersHash();

  @$internal
  @override
  ActiveTimers create() => ActiveTimers();
}

String _$activeTimersHash() => r'978331c653894624921957df38127cc3796e3bba';

abstract class _$ActiveTimers extends $AsyncNotifier<List<TimerEntity>> {
  FutureOr<List<TimerEntity>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<TimerEntity>>, List<TimerEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TimerEntity>>, List<TimerEntity>>,
              AsyncValue<List<TimerEntity>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
