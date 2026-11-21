import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/data/database/app_database.dart';
import 'package:multi_timer/data/repositories/sqlite_preset_repository.dart';
import 'package:multi_timer/data/repositories/sqlite_timer_repository.dart';
import 'package:multi_timer/domain/entities/preset.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final base = DateTime(2026, 1, 1, 12, 0, 0);

  late AppDatabase appDatabase;
  late SqlitePresetRepository repository;
  late SqliteTimerRepository timerRepository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    appDatabase = AppDatabase(path: inMemoryDatabasePath);
    repository = SqlitePresetRepository(appDatabase: appDatabase);
    timerRepository = SqliteTimerRepository(appDatabase: appDatabase);
  });

  tearDown(() async {
    final db = await appDatabase.database;
    await db.close();
  });

  PresetEntity buildPreset({String name = 'Preset', int position = 0}) {
    return PresetEntity(
      name: name,
      durationSeconds: 300,
      color: 0xFF2196F3,
      soundId: 'default',
      createdAt: base,
      position: position,
    );
  }

  group('insert', () {
    test('devolve a entidade com o id gerado e grava no banco', () async {
      final inserted = await repository.insert(
        buildPreset(name: 'Ovo cozido', position: 3),
      );

      expect(inserted.id, isNotNull);

      final saved = await repository.getById(inserted.id!);
      expect(saved!.name, 'Ovo cozido');
      expect(saved.durationSeconds, 300);
      expect(saved.color, 0xFF2196F3);
      expect(saved.soundId, 'default');
      expect(saved.createdAt, base);
      expect(saved.position, 3);
    });

    test('gera ids diferentes para cada preset', () async {
      final first = await repository.insert(buildPreset());
      final second = await repository.insert(buildPreset());

      expect(first.id, isNot(second.id));
    });
  });

  group('getById', () {
    test('devolve o preset quando ele existe', () async {
      final inserted = await repository.insert(buildPreset(name: 'Café'));

      final found = await repository.getById(inserted.id!);

      expect(found, isNotNull);
      expect(found!.id, inserted.id);
      expect(found.name, 'Café');
    });

    test('devolve null quando o id não existe', () async {
      final found = await repository.getById(999);

      expect(found, isNull);
    });
  });

  group('getAll', () {
    test('devolve os presets ordenados por position', () async {
      await repository.insert(buildPreset(name: 'C', position: 2));
      await repository.insert(buildPreset(name: 'A', position: 0));
      await repository.insert(buildPreset(name: 'B', position: 1));

      final all = await repository.getAll();

      expect(all.map((preset) => preset.name), ['A', 'B', 'C']);
    });

    test('sem presets devolve lista vazia', () async {
      final all = await repository.getAll();

      expect(all, isEmpty);
    });
  });

  group('update', () {
    test('altera o registro existente', () async {
      final inserted = await repository.insert(buildPreset(name: 'Antigo'));

      await repository.update(inserted.copyWith(name: 'Novo'));

      final saved = await repository.getById(inserted.id!);
      expect(saved!.name, 'Novo');
    });

    test('id inexistente lança StateError', () async {
      final ghost = buildPreset().copyWith(id: 999);

      await expectLater(repository.update(ghost), throwsStateError);
    });
  });

  group('delete', () {
    test('remove só o preset informado', () async {
      final first = await repository.insert(buildPreset(name: 'A'));
      final second = await repository.insert(buildPreset(name: 'B'));

      await repository.delete(first.id!);

      expect(await repository.getById(first.id!), isNull);
      expect(await repository.getById(second.id!), isNotNull);
    });

    test(
      'excluir um preset zera o presetId dos timers sem apagá-los',
      () async {
        final preset = await repository.insert(buildPreset());
        final timer = await timerRepository.insert(
          TimerEntity(
            name: 'Timer',
            soundId: 'default',
            color: 0xFF000000,
            durationSeconds: 60,
            remainingSeconds: 60,
            notificationId: 1,
            createdAt: base,
            finishedAt: base,
            presetId: preset.id,
            status: TimerStatus.stopped,
          ),
        );

        await repository.delete(preset.id!);

        final saved = await timerRepository.getById(timer.id!);
        expect(saved, isNotNull);
        expect(saved!.presetId, isNull);
      },
    );
  });

  group('reorder', () {
    test('grava a nova ordem sem alterar os outros campos', () async {
      final a = await repository.insert(buildPreset(name: 'A', position: 0));
      final b = await repository.insert(buildPreset(name: 'B', position: 1));
      final c = await repository.insert(buildPreset(name: 'C', position: 2));

      await repository.reorder([c, a, b]);

      final all = await repository.getAll();
      expect(all.map((preset) => preset.name), ['C', 'A', 'B']);
      expect(all.map((preset) => preset.position), [0, 1, 2]);
      expect(all.every((preset) => preset.durationSeconds == 300), isTrue);
    });

    test('lista vazia não altera nada', () async {
      await repository.insert(buildPreset(name: 'A', position: 0));

      await repository.reorder([]);

      final all = await repository.getAll();
      expect(all.map((preset) => preset.name), ['A']);
    });
  });
}
