import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/data/database/app_database.dart';
import 'package:multi_timer/domain/entities/preset.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/presentation/providers/active_timers_provider.dart';
import 'package:multi_timer/presentation/providers/dependency_providers.dart';
import 'package:multi_timer/presentation/providers/presets_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);

  late AppDatabase appDatabase;
  late ProviderContainer container;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    appDatabase = AppDatabase(path: inMemoryDatabasePath);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDatabase),
        clockProvider.overrideWithValue(() => fixedNow),
      ],
    );
    addTearDown(container.dispose);
    container.listen(presetsProvider, (previous, next) {});
  });

  tearDown(() async {
    final db = await appDatabase.database;
    await db.close();
  });

  Future<List<PresetEntity>> loadPresets() {
    return container.read(presetsProvider.future);
  }

  Presets notifier() => container.read(presetsProvider.notifier);

  List<PresetEntity> presetsState() {
    return container.read(presetsProvider).requireValue;
  }

  Future<void> addPreset(String name) {
    return notifier().add(
      name: name,
      durationSeconds: 300,
      color: 0xFF2196F3,
      soundId: 'default',
    );
  }

  group('build', () {
    test('sem presets devolve lista vazia', () async {
      final presets = await loadPresets();

      expect(presets, isEmpty);
    });
  });

  group('add', () {
    test('primeiro preset recebe position 0 e createdAt do relógio', () async {
      await loadPresets();

      await addPreset('A');

      final preset = presetsState().single;
      expect(preset.id, isNotNull);
      expect(preset.position, 0);
      expect(preset.createdAt, fixedNow);
    });

    test('os seguintes entram no fim da lista', () async {
      await loadPresets();

      await addPreset('A');
      await addPreset('B');
      await addPreset('C');

      expect(presetsState().map((preset) => preset.name), ['A', 'B', 'C']);
      expect(presetsState().map((preset) => preset.position), [0, 1, 2]);
    });

    test('depois de remover do meio não repete posição', () async {
      await loadPresets();
      await addPreset('A');
      await addPreset('B');
      await addPreset('C');
      final middle = presetsState()[1];

      await notifier().remove(middle.id!);
      await addPreset('D');

      expect(presetsState().map((preset) => preset.name), ['A', 'C', 'D']);
      expect(presetsState().map((preset) => preset.position), [0, 2, 3]);
    });
  });

  group('edit', () {
    test('altera o preset na lista', () async {
      await loadPresets();
      await addPreset('Antigo');

      await notifier().edit(presetsState().single.copyWith(name: 'Novo'));

      expect(presetsState().single.name, 'Novo');
    });
  });

  group('remove', () {
    test('tira o preset da lista e zera o presetId dos timers', () async {
      await loadPresets();
      await addPreset('A');
      final preset = presetsState().single;
      await container
          .read(timerRepositoryProvider)
          .insert(
            TimerEntity(
              name: 'Timer',
              soundId: 'default',
              color: 0xFF000000,
              durationSeconds: 60,
              remainingSeconds: 60,
              notificationId: 1,
              createdAt: fixedNow,
              presetId: preset.id,
              status: TimerStatus.paused,
            ),
          );
      final before = await container.read(activeTimersProvider.future);
      expect(before.single.presetId, preset.id);

      await notifier().remove(preset.id!);

      expect(presetsState(), isEmpty);
      final after = await container.read(activeTimersProvider.future);
      expect(after.single.presetId, isNull);
    });
  });

  group('reorder', () {
    test('atualiza a lista e grava a nova ordem', () async {
      await loadPresets();
      await addPreset('A');
      await addPreset('B');
      await addPreset('C');
      final current = presetsState();

      await notifier().reorder([current[2], current[0], current[1]]);

      expect(presetsState().map((preset) => preset.name), ['C', 'A', 'B']);

      final saved = await container.read(presetRepositoryProvider).getAll();
      expect(saved.map((preset) => preset.name), ['C', 'A', 'B']);
      expect(saved.map((preset) => preset.position), [0, 1, 2]);
    });
  });
}
