import 'package:multi_timer/domain/entities/preset.dart';
import 'package:multi_timer/presentation/providers/active_timers_provider.dart';
import 'package:multi_timer/presentation/providers/dependency_providers.dart';
import 'package:multi_timer/presentation/providers/history_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'presets_provider.g.dart';

@riverpod
class Presets extends _$Presets {
  @override
  Future<List<PresetEntity>> build() async {
    return await ref.read(presetRepositoryProvider).getAll();
  }

  Future<void> add({
    required String name,
    required int durationSeconds,
    required int color,
    required String soundId,
  }) async {
    final now = ref.read(clockProvider)();
    final presets = await ref.read(presetRepositoryProvider).getAll();

    final position = presets.isEmpty ? 0 : presets.last.position + 1;

    final preset = PresetEntity(
      name: name,
      durationSeconds: durationSeconds,
      color: color,
      soundId: soundId,
      createdAt: now,
      position: position,
    );

    await ref.read(presetRepositoryProvider).insert(preset);
    await _reload();
  }

  Future<void> edit(PresetEntity preset) async {
    await ref.read(presetRepositoryProvider).update(preset);
    await _reload();
  }

  Future<void> remove(int presetId) async {
    await ref.read(presetRepositoryProvider).delete(presetId);
    await _reload();
    ref.invalidate(activeTimersProvider);
    ref.invalidate(historyProvider);
  }

  Future<void> reorder(List<PresetEntity> reordered) async {
    state = AsyncData(reordered);
    await ref.read(presetRepositoryProvider).reorder(reordered);
    await _reload();
  }

  Future<void> _reload() async {
    state = AsyncData(await ref.read(presetRepositoryProvider).getAll());
  }
}
