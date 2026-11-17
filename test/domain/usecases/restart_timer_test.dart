import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/usecases/restart_timer.dart';

import '../fakes/fake_alarm_scheduler.dart';
import '../fakes/fake_timer_repository.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);
  const notificationId = 123;

  late FakeTimerRepository repository;
  late FakeAlarmScheduler scheduler;
  late RestartTimer restartTimer;

  setUp(() {
    repository = FakeTimerRepository();
    scheduler = FakeAlarmScheduler();
    restartTimer = RestartTimer(
      repository: repository,
      scheduler: scheduler,
      now: () => fixedNow,
    );
  });

  Future<TimerEntity> insertTimer({
    required TimerStatus status,
    Duration? endsIn,
    int durationSeconds = 120,
    int remainingSeconds = 60,
  }) {
    final isClosed =
        status == TimerStatus.finished || status == TimerStatus.stopped;

    return repository.insert(
      TimerEntity(
        name: 'Timer 1',
        soundId: 'default',
        color: 0xFF000000,
        durationSeconds: durationSeconds,
        remainingSeconds: remainingSeconds,
        notificationId: notificationId,
        createdAt: fixedNow,
        status: status,
        endsAt: endsIn == null ? null : fixedNow.add(endsIn),
        finishedAt: isClosed ? fixedNow : null,
      ),
    );
  }

  group('RestartTimer - timer em andamento', () {
    test('volta ao tempo total e continua rodando', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: 30),
      );

      final restarted = await restartTimer(timerId: timer.id!);

      expect(restarted.status, TimerStatus.running);
      expect(restarted.endsAt, fixedNow.add(const Duration(seconds: 120)));
      expect(restarted.remainingSeconds, 120);

      final saved = await repository.getById(timer.id!);
      expect(saved!.endsAt, fixedNow.add(const Duration(seconds: 120)));
    });

    test('reagenda o alarme substituindo o anterior', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: 30),
      );
      scheduler.scheduled[timer.notificationId] = timer.endsAt!;

      final restarted = await restartTimer(timerId: timer.id!);

      expect(scheduler.scheduled, hasLength(1));
      expect(scheduler.scheduled[timer.notificationId], restarted.endsAt);
    });

    test('timer que recebeu +1 min reinicia com a duração original', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: 150),
        durationSeconds: 90,
      );

      final restarted = await restartTimer(timerId: timer.id!);

      expect(restarted.endsAt, fixedNow.add(const Duration(seconds: 90)));
      expect(restarted.remainingSeconds, 90);
    });
  });

  group('RestartTimer - timer pausado', () {
    test('volta ao tempo total e continua pausado, sem alarme', () async {
      final timer = await insertTimer(
        status: TimerStatus.paused,
        remainingSeconds: 10,
      );

      final restarted = await restartTimer(timerId: timer.id!);

      expect(restarted.status, TimerStatus.paused);
      expect(restarted.remainingSeconds, 120);
      expect(restarted.endsAt, isNull);
      expect(scheduler.scheduled, isEmpty);

      final saved = await repository.getById(timer.id!);
      expect(saved!.status, TimerStatus.paused);
      expect(saved.remainingSeconds, 120);
    });
  });

  group('RestartTimer - erros', () {
    for (final status in [TimerStatus.finished, TimerStatus.stopped]) {
      test('timer ${status.name} lança InvalidTimerStateException', () async {
        final timer = await insertTimer(status: status);

        await expectLater(
          restartTimer(timerId: timer.id!),
          throwsA(isA<InvalidTimerStateException>()),
        );

        final saved = await repository.getById(timer.id!);
        expect(saved!.status, status);
        expect(scheduler.scheduled, isEmpty);
      });
    }

    test('id inexistente lança TimerNotFoundException', () async {
      await expectLater(
        restartTimer(timerId: 999),
        throwsA(isA<TimerNotFoundException>()),
      );

      expect(scheduler.scheduled, isEmpty);
    });
  });
}
