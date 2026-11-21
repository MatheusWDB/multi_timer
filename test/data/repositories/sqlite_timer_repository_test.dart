import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/data/database/app_database.dart';
import 'package:multi_timer/data/repositories/sqlite_timer_repository.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final base = DateTime(2026, 1, 1, 12, 0, 0);

  late AppDatabase appDatabase;
  late SqliteTimerRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    appDatabase = AppDatabase(path: inMemoryDatabasePath);
    repository = SqliteTimerRepository(appDatabase: appDatabase);
  });

  tearDown(() async {
    final db = await appDatabase.database;
    await db.close();
  });

  TimerEntity buildTimer({
    TimerStatus status = TimerStatus.running,
    DateTime? createdAt,
    DateTime? endsAt,
    DateTime? finishedAt,
  }) {
    return TimerEntity(
      name: 'Timer',
      soundId: 'default',
      color: 0xFF000000,
      durationSeconds: 60,
      remainingSeconds: 60,
      notificationId: 1,
      createdAt: createdAt ?? base,
      endsAt: endsAt,
      finishedAt: finishedAt,
      status: status,
    );
  }

  group('insert', () {
    test('devolve a entidade com o id gerado e grava no banco', () async {
      final inserted = await repository.insert(
        buildTimer(endsAt: base.add(const Duration(seconds: 60))),
      );

      expect(inserted.id, isNotNull);

      final saved = await repository.getById(inserted.id!);
      expect(saved!.name, 'Timer');
      expect(saved.status, TimerStatus.running);
      expect(saved.endsAt, base.add(const Duration(seconds: 60)));
      expect(saved.createdAt, base);
    });

    test('gera ids diferentes para cada timer', () async {
      final first = await repository.insert(buildTimer());
      final second = await repository.insert(buildTimer());

      expect(first.id, isNot(second.id));
    });
  });

  group('getById', () {
    test('devolve o timer quando ele existe', () async {
      final inserted = await repository.insert(buildTimer());

      final found = await repository.getById(inserted.id!);

      expect(found, isNotNull);
      expect(found!.id, inserted.id);
    });

    test('devolve null quando o id não existe', () async {
      final found = await repository.getById(999);

      expect(found, isNull);
    });
  });

  group('getActiveTimers', () {
    test(
      'devolve só running e paused, do mais novo para o mais antigo',
      () async {
        final oldest = await repository.insert(buildTimer(createdAt: base));
        final newest = await repository.insert(
          buildTimer(
            status: TimerStatus.paused,
            createdAt: base.add(const Duration(minutes: 1)),
          ),
        );
        await repository.insert(
          buildTimer(status: TimerStatus.finished, finishedAt: base),
        );
        await repository.insert(
          buildTimer(status: TimerStatus.stopped, finishedAt: base),
        );

        final active = await repository.getActiveTimers();

        expect(active.map((timer) => timer.id), [newest.id, oldest.id]);
      },
    );
  });

  group('getHistoryTimers', () {
    test(
      'devolve só finished e stopped, do mais recente para o mais antigo',
      () async {
        final first = await repository.insert(
          buildTimer(
            status: TimerStatus.finished,
            finishedAt: base.add(const Duration(minutes: 1)),
          ),
        );
        final second = await repository.insert(
          buildTimer(
            status: TimerStatus.stopped,
            finishedAt: base.add(const Duration(minutes: 5)),
          ),
        );
        await repository.insert(buildTimer());
        await repository.insert(buildTimer(status: TimerStatus.paused));

        final history = await repository.getHistoryTimers();

        expect(history.map((timer) => timer.id), [second.id, first.id]);
      },
    );
  });

  group('update', () {
    test('altera o registro existente', () async {
      final inserted = await repository.insert(
        buildTimer(endsAt: base.add(const Duration(seconds: 60))),
      );

      await repository.update(
        inserted.copyWith(
          status: TimerStatus.paused,
          endsAt: () => null,
          remainingSeconds: 30,
        ),
      );

      final saved = await repository.getById(inserted.id!);
      expect(saved!.status, TimerStatus.paused);
      expect(saved.endsAt, isNull);
      expect(saved.remainingSeconds, 30);
    });

    test('id inexistente lança StateError', () async {
      final ghost = buildTimer().copyWith(id: 999);

      await expectLater(repository.update(ghost), throwsStateError);
    });
  });

  group('delete', () {
    test('remove só o timer informado', () async {
      final first = await repository.insert(buildTimer());
      final second = await repository.insert(buildTimer());

      await repository.delete(first.id!);

      expect(await repository.getById(first.id!), isNull);
      expect(await repository.getById(second.id!), isNotNull);
    });
  });

  group('clearHistory', () {
    test('remove os encerrados e mantém os ativos', () async {
      await repository.insert(buildTimer());
      await repository.insert(buildTimer(status: TimerStatus.paused));
      await repository.insert(
        buildTimer(status: TimerStatus.finished, finishedAt: base),
      );
      await repository.insert(
        buildTimer(status: TimerStatus.stopped, finishedAt: base),
      );

      await repository.clearHistory();

      expect(await repository.getHistoryTimers(), isEmpty);
      expect(await repository.getActiveTimers(), hasLength(2));
    });
  });

  group('deleteHistoryOlderThan', () {
    final limit = base.add(const Duration(minutes: 10));

    test('remove encerrados antigos e mantém recentes e ativos', () async {
      final oldClosed = await repository.insert(
        buildTimer(
          status: TimerStatus.finished,
          finishedAt: base.add(const Duration(minutes: 1)),
        ),
      );
      final recentClosed = await repository.insert(
        buildTimer(
          status: TimerStatus.stopped,
          finishedAt: base.add(const Duration(minutes: 20)),
        ),
      );
      final oldRunning = await repository.insert(buildTimer(createdAt: base));

      await repository.deleteHistoryOlderThan(limit);

      expect(await repository.getById(oldClosed.id!), isNull);
      expect(await repository.getById(recentClosed.id!), isNotNull);
      expect(await repository.getById(oldRunning.id!), isNotNull);
    });

    test('timer encerrado exatamente no limite é mantido', () async {
      final atLimit = await repository.insert(
        buildTimer(status: TimerStatus.finished, finishedAt: limit),
      );

      await repository.deleteHistoryOlderThan(limit);

      expect(await repository.getById(atLimit.id!), isNotNull);
    });
  });
}
