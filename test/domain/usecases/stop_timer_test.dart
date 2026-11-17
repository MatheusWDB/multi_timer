import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/usecases/stop_timer.dart';

import '../fakes/fake_alarm_scheduler.dart';
import '../fakes/fake_timer_repository.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);
  final finishedBefore = fixedNow.subtract(const Duration(minutes: 5));
  const notificationId = 123;

  late FakeTimerRepository repository;
  late FakeAlarmScheduler scheduler;
  late StopTimer stopTimer;

  setUp(() {
    repository = FakeTimerRepository();
    scheduler = FakeAlarmScheduler();
    stopTimer = StopTimer(
      repository: repository,
      scheduler: scheduler,
      now: () => fixedNow,
    );
  });

  Future<TimerEntity> insertTimer({
    required TimerStatus status,
    Duration? endsIn,
    int remainingSeconds = 60,
  }) {
    final isClosed =
        status == TimerStatus.finished || status == TimerStatus.stopped;

    return repository.insert(
      TimerEntity(
        name: 'Timer 1',
        soundId: 'default',
        color: 0xFF000000,
        durationSeconds: 60,
        remainingSeconds: remainingSeconds,
        notificationId: notificationId,
        createdAt: fixedNow,
        status: status,
        endsAt: endsIn == null ? null : fixedNow.add(endsIn),
        finishedAt: isClosed ? finishedBefore : null,
      ),
    );
  }

  group('StopTimer - fluxo normal', () {
    test('timer em andamento vira stopped e o alarme é cancelado', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: 90),
      );
      scheduler.scheduled[timer.notificationId] = timer.endsAt!;

      final stopped = await stopTimer(timerId: timer.id!);

      expect(stopped.status, TimerStatus.stopped);
      expect(stopped.endsAt, isNull);
      expect(stopped.finishedAt, fixedNow);
      expect(scheduler.scheduled, isEmpty);
      expect(scheduler.cancelled, [timer.notificationId]);
    });

    test('grava o timer parado no repositório', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: 90),
      );

      await stopTimer(timerId: timer.id!);

      final saved = await repository.getById(timer.id!);
      expect(saved!.status, TimerStatus.stopped);
      expect(saved.endsAt, isNull);
      expect(saved.finishedAt, fixedNow);
    });

    test('timer pausado vira stopped sem cancelar alarme', () async {
      final timer = await insertTimer(
        status: TimerStatus.paused,
        remainingSeconds: 45,
      );

      final stopped = await stopTimer(timerId: timer.id!);

      expect(stopped.status, TimerStatus.stopped);
      expect(stopped.finishedAt, fixedNow);
      expect(scheduler.cancelled, isEmpty);

      final saved = await repository.getById(timer.id!);
      expect(saved!.status, TimerStatus.stopped);
    });
  });

  group('StopTimer - timers já encerrados', () {
    for (final status in [TimerStatus.finished, TimerStatus.stopped]) {
      test('timer ${status.name} é devolvido sem alterações', () async {
        final timer = await insertTimer(status: status);

        final result = await stopTimer(timerId: timer.id!);

        expect(result.status, status);
        expect(result.finishedAt, finishedBefore);

        final saved = await repository.getById(timer.id!);
        expect(saved!.status, status);
        expect(saved.finishedAt, finishedBefore);
        expect(scheduler.cancelled, isEmpty);
      });
    }
  });

  group('StopTimer - erros', () {
    test('id inexistente lança TimerNotFoundException', () async {
      await expectLater(
        stopTimer(timerId: 999),
        throwsA(isA<TimerNotFoundException>()),
      );

      expect(scheduler.cancelled, isEmpty);
    });
  });
}
