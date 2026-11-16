import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/usecases/pause_timer.dart';

import '../fakes/fake_alarm_scheduler.dart';
import '../fakes/fake_timer_repository.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);
  const notificationId = 123;

  late FakeTimerRepository repository;
  late FakeAlarmScheduler scheduler;
  late PauseTimer pauseTimer;

  setUp(() {
    repository = FakeTimerRepository();
    scheduler = FakeAlarmScheduler();
    pauseTimer = PauseTimer(
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
      ),
    );
  }

  group('PauseTimer - fluxo normal', () {
    test('pausa o timer, zera o endsAt e cancela o alarme', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: 90),
      );
      scheduler.scheduled[timer.notificationId] = timer.endsAt!;

      final paused = await pauseTimer(timerId: timer.id!);

      expect(paused.status, TimerStatus.paused);
      expect(paused.endsAt, isNull);
      expect(paused.remainingSeconds, 90);
      expect(scheduler.scheduled, isEmpty);
      expect(scheduler.cancelled, [timer.notificationId]);
    });

    test('grava o timer pausado no repositório', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: 90),
      );

      await pauseTimer(timerId: timer.id!);

      final saved = await repository.getById(timer.id!);
      expect(saved!.status, TimerStatus.paused);
      expect(saved.endsAt, isNull);
      expect(saved.remainingSeconds, 90);
    });
  });

  group('PauseTimer - erros', () {
    test('id inexistente lança TimerNotFoundException', () async {
      await expectLater(
        pauseTimer(timerId: 999),
        throwsA(isA<TimerNotFoundException>()),
      );

      expect(scheduler.cancelled, isEmpty);
    });

    for (final status in [
      TimerStatus.paused,
      TimerStatus.finished,
      TimerStatus.stopped,
    ]) {
      test('timer ${status.name} lança InvalidTimerStateException', () async {
        final timer = await insertTimer(status: status);

        await expectLater(
          pauseTimer(timerId: timer.id!),
          throwsA(isA<InvalidTimerStateException>()),
        );

        final saved = await repository.getById(timer.id!);
        expect(saved!.status, status);
        expect(scheduler.cancelled, isEmpty);
      });
    }
  });

  group('PauseTimer - arredondamento', () {
    test('arredonda o tempo restante para cima', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(milliseconds: 4200),
      );

      final paused = await pauseTimer(timerId: timer.id!);

      expect(paused.remainingSeconds, 5);
    });

    test('nunca pausa com menos de 1 segundo restante', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(milliseconds: 100),
      );

      final paused = await pauseTimer(timerId: timer.id!);

      expect(paused.remainingSeconds, 1);
    });

    test('timer com endsAt já vencido pausa com 1 segundo', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: -2),
      );

      final paused = await pauseTimer(timerId: timer.id!);

      expect(paused.remainingSeconds, 1);
    });
  });
}
