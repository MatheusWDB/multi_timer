// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(History)
final historyProvider = HistoryProvider._();

final class HistoryProvider
    extends $AsyncNotifierProvider<History, List<TimerEntity>> {
  HistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyHash();

  @$internal
  @override
  History create() => History();
}

String _$historyHash() => r'79e7058ffc0656f4de184fcdaf69f47cfcf49a95';

abstract class _$History extends $AsyncNotifier<List<TimerEntity>> {
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
