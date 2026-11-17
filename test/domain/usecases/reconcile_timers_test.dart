import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/usecases/finish_timer.dart';
import 'package:multi_timer/domain/usecases/reconcile_timers.dart';

import '../fakes/fake_alarm_scheduler.dart';
import '../fakes/fake_timer_repository.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);
  final finishedBefore = fixedNow.subtract(const Duration(minutes: 5));

  late FakeTimerRepository repository;
  late FakeAlarmScheduler scheduler;
  late ReconcileTimers reconcileTimers;

  setUp(() {
    repository = FakeTimerRepository();
    scheduler = FakeAlarmScheduler();
    reconcileTimers = ReconcileTimers(
      repository: repository,
      scheduler: scheduler,
      now: () => fixedNow,
      finishTimer: FinishTimer(repository: repository, now: () => fixedNow),
    );
  });

  Future<TimerEntity> insertTimer({
    required TimerStatus status,
    required int notificationId,
    Duration? endsIn,
  }) {
    final isClosed =
        status == TimerStatus.finished || status == TimerStatus.stopped;

    return repository.insert(
      TimerEntity(
        name: 'Timer $notificationId',
        soundId: 'default',
        color: 0xFF000000,
        durationSeconds: 600,
        remainingSeconds: 600,
        notificationId: notificationId,
        createdAt: fixedNow,
        status: status,
        endsAt: endsIn == null ? null : fixedNow.add(endsIn),
        finishedAt: isClosed ? finishedBefore : null,
      ),
    );
  }

  group('ReconcileTimers - timer vencido', () {
    test('vira finished, é devolvido na lista e não agenda alarme', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: const Duration(minutes: -5),
      );

      final finished = await reconcileTimers();

      expect(finished, hasLength(1));
      expect(finished.first.id, timer.id);
      expect(finished.first.status, TimerStatus.finished);
      expect(scheduler.scheduled, isEmpty);

      final saved = await repository.getById(timer.id!);
      expect(saved!.status, TimerStatus.finished);
      expect(saved.endsAt, isNull);
      expect(saved.finishedAt, timer.endsAt);
    });

    test('endsAt exatamente igual a agora também finaliza', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: Duration.zero,
      );

      final finished = await reconcileTimers();

      expect(finished.map((item) => item.id), [timer.id]);
    });
  });

  group('ReconcileTimers - timer ainda em andamento', () {
    test('continua running e tem o alarme reagendado', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: const Duration(minutes: 10),
      );

      final finished = await reconcileTimers();

      expect(finished, isEmpty);
      expect(scheduler.scheduled[timer.notificationId], timer.endsAt);

      final saved = await repository.getById(timer.id!);
      expect(saved!.status, TimerStatus.running);
    });
  });

  group('ReconcileTimers - timers sem alarme', () {
    test('timer pausado não é alterado e não agenda alarme', () async {
      final timer = await insertTimer(
        status: TimerStatus.paused,
        notificationId: 1,
      );

      final finished = await reconcileTimers();

      expect(finished, isEmpty);
      expect(scheduler.scheduled, isEmpty);

      final saved = await repository.getById(timer.id!);
      expect(saved!.status, TimerStatus.paused);
    });

    test('repositório vazio devolve lista vazia', () async {
      final finished = await reconcileTimers();

      expect(finished, isEmpty);
      expect(scheduler.scheduled, isEmpty);
    });
  });

  group('ReconcileTimers - vários timers', () {
    test('trata cada timer conforme a sua situação', () async {
      final expired = await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: const Duration(minutes: -1),
      );
      final upcoming = await insertTimer(
        status: TimerStatus.running,
        notificationId: 2,
        endsIn: const Duration(minutes: 30),
      );
      final paused = await insertTimer(
        status: TimerStatus.paused,
        notificationId: 3,
      );
      final closed = await insertTimer(
        status: TimerStatus.finished,
        notificationId: 4,
      );

      final finished = await reconcileTimers();

      expect(finished.map((item) => item.id), [expired.id]);
      expect(scheduler.scheduled, hasLength(1));
      expect(scheduler.scheduled[upcoming.notificationId], upcoming.endsAt);

      final savedPaused = await repository.getById(paused.id!);
      expect(savedPaused!.status, TimerStatus.paused);

      final savedClosed = await repository.getById(closed.id!);
      expect(savedClosed!.finishedAt, finishedBefore);
    });

    test('rodar duas vezes seguidas não duplica nem altera nada', () async {
      await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: const Duration(minutes: -1),
      );
      final upcoming = await insertTimer(
        status: TimerStatus.running,
        notificationId: 2,
        endsIn: const Duration(minutes: 30),
      );

      await reconcileTimers();
      final secondRun = await reconcileTimers();

      expect(secondRun, isEmpty);
      expect(scheduler.scheduled, hasLength(1));
      expect(scheduler.scheduled[upcoming.notificationId], upcoming.endsAt);
    });
  });
}
