// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Presets)
final presetsProvider = PresetsProvider._();

final class PresetsProvider
    extends $AsyncNotifierProvider<Presets, List<PresetEntity>> {
  PresetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presetsHash();

  @$internal
  @override
  Presets create() => Presets();
}

String _$presetsHash() => r'6bca7a3577c6a2ca9097a78dd69567cdefbc8d51';

abstract class _$Presets extends $AsyncNotifier<List<PresetEntity>> {
  FutureOr<List<PresetEntity>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PresetEntity>>, List<PresetEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PresetEntity>>, List<PresetEntity>>,
              AsyncValue<List<PresetEntity>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
