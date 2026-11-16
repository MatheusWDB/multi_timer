import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/usecases/resume_timer.dart';

import '../fakes/fake_alarm_scheduler.dart';
import '../fakes/fake_timer_repository.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);
  const notificationId = 123;

  late FakeTimerRepository repository;
  late FakeAlarmScheduler scheduler;
  late ResumeTimer resumeTimer;

  setUp(() {
    repository = FakeTimerRepository();
    scheduler = FakeAlarmScheduler();
    resumeTimer = ResumeTimer(
      repository: repository,
      scheduler: scheduler,
      now: () => fixedNow,
    );
  });

  Future<TimerEntity> insertTimer({
    required TimerStatus status,
    int remainingSeconds = 60,
  }) {
    return repository.insert(
      TimerEntity(
        name: 'Timer 1',
        soundId: 'default',
        color: 0xFF000000,
        durationSeconds: 120,
        remainingSeconds: remainingSeconds,
        notificationId: notificationId,
        createdAt: fixedNow,
        status: status,
      ),
    );
  }

  group('ResumeTimer - fluxo normal', () {
    test('retoma o timer com endsAt = agora + remainingSeconds', () async {
      final timer = await insertTimer(
        status: TimerStatus.paused,
        remainingSeconds: 90,
      );

      final resumed = await resumeTimer(timerId: timer.id!);

      expect(resumed.status, TimerStatus.running);
      expect(resumed.endsAt, fixedNow.add(const Duration(seconds: 90)));
    });

    test('reagenda o alarme para o novo endsAt', () async {
      final timer = await insertTimer(
        status: TimerStatus.paused,
        remainingSeconds: 90,
      );

      final resumed = await resumeTimer(timerId: timer.id!);

      expect(scheduler.scheduled[timer.notificationId], resumed.endsAt);
      expect(scheduler.scheduled, hasLength(1));
    });

    test('grava o timer retomado no repositório', () async {
      final timer = await insertTimer(
        status: TimerStatus.paused,
        remainingSeconds: 90,
      );

      await resumeTimer(timerId: timer.id!);

      final saved = await repository.getById(timer.id!);
      expect(saved!.status, TimerStatus.running);
      expect(saved.endsAt, fixedNow.add(const Duration(seconds: 90)));
    });
  });

  group('ResumeTimer - erros', () {
    test('id inexistente lança TimerNotFoundException', () async {
      await expectLater(
        resumeTimer(timerId: 999),
        throwsA(isA<TimerNotFoundException>()),
      );

      expect(scheduler.scheduled, isEmpty);
    });

    for (final status in [
      TimerStatus.running,
      TimerStatus.finished,
      TimerStatus.stopped,
    ]) {
      test('timer ${status.name} lança InvalidTimerStateException', () async {
        final timer = await insertTimer(status: status);

        await expectLater(
          resumeTimer(timerId: timer.id!),
          throwsA(isA<InvalidTimerStateException>()),
        );

        final saved = await repository.getById(timer.id!);
        expect(saved!.status, status);
        expect(scheduler.scheduled, isEmpty);
      });
    }

    test(
      'retomar duas vezes seguidas lança InvalidTimerStateException',
      () async {
        final timer = await insertTimer(status: TimerStatus.paused);

        await resumeTimer(timerId: timer.id!);

        await expectLater(
          resumeTimer(timerId: timer.id!),
          throwsA(isA<InvalidTimerStateException>()),
        );
      },
    );
  });

  group('ResumeTimer - bordas', () {
    test('retoma com apenas 1 segundo restante', () async {
      final timer = await insertTimer(
        status: TimerStatus.paused,
        remainingSeconds: 1,
      );

      final resumed = await resumeTimer(timerId: timer.id!);

      expect(resumed.endsAt, fixedNow.add(const Duration(seconds: 1)));
    });
  });
}
