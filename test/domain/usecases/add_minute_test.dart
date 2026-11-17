import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/core/constants/app_limits.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/usecases/add_minute.dart';

import '../fakes/fake_alarm_scheduler.dart';
import '../fakes/fake_timer_repository.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);
  const notificationId = 123;

  late FakeTimerRepository repository;
  late FakeAlarmScheduler scheduler;
  late AddMinute addMinute;

  setUp(() {
    repository = FakeTimerRepository();
    scheduler = FakeAlarmScheduler();
    addMinute = AddMinute(
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
        finishedAt: status == TimerStatus.finished ? fixedNow : null,
      ),
    );
  }

  group('AddMinute - timer em andamento', () {
    test('soma 60 segundos ao endsAt e mantém running', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: 90),
      );

      final updated = await addMinute(timerId: timer.id!);

      expect(updated.status, TimerStatus.running);
      expect(updated.endsAt, fixedNow.add(const Duration(seconds: 150)));

      final saved = await repository.getById(timer.id!);
      expect(saved!.endsAt, fixedNow.add(const Duration(seconds: 150)));
    });

    test('reagenda o alarme substituindo o anterior', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: 90),
      );
      scheduler.scheduled[timer.notificationId] = timer.endsAt!;

      final updated = await addMinute(timerId: timer.id!);

      expect(scheduler.scheduled, hasLength(1));
      expect(scheduler.scheduled[timer.notificationId], updated.endsAt);
    });

    test('com endsAt já vencido, soma 60 s a partir de agora', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: -120),
      );

      final updated = await addMinute(timerId: timer.id!);

      expect(updated.endsAt, fixedNow.add(const Duration(seconds: 60)));
      expect(scheduler.scheduled[timer.notificationId], updated.endsAt);
    });

    test('aceita a soma que chega exatamente ao teto de duração', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: Duration(
          seconds: AppLimits.maxDurationSeconds - AppLimits.addTimeSeconds,
        ),
      );

      final updated = await addMinute(timerId: timer.id!);

      expect(
        updated.endsAt,
        fixedNow.add(Duration(seconds: AppLimits.maxDurationSeconds)),
      );
    });

    test('soma que passa do teto lança InvalidDurationException', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: Duration(
          seconds: AppLimits.maxDurationSeconds - AppLimits.addTimeSeconds + 1,
        ),
      );
      scheduler.scheduled[timer.notificationId] = timer.endsAt!;

      await expectLater(
        addMinute(timerId: timer.id!),
        throwsA(isA<InvalidDurationException>()),
      );

      final saved = await repository.getById(timer.id!);
      expect(saved!.endsAt, timer.endsAt);
      expect(scheduler.scheduled[timer.notificationId], timer.endsAt);
    });
  });

  group('AddMinute - timer pausado', () {
    test('soma 60 segundos ao remainingSeconds sem agendar alarme', () async {
      final timer = await insertTimer(
        status: TimerStatus.paused,
        remainingSeconds: 90,
      );

      final updated = await addMinute(timerId: timer.id!);

      expect(updated.status, TimerStatus.paused);
      expect(updated.remainingSeconds, 150);
      expect(updated.endsAt, isNull);
      expect(scheduler.scheduled, isEmpty);

      final saved = await repository.getById(timer.id!);
      expect(saved!.remainingSeconds, 150);
    });

    test('aceita a soma que chega exatamente ao teto de duração', () async {
      final timer = await insertTimer(
        status: TimerStatus.paused,
        remainingSeconds:
            AppLimits.maxDurationSeconds - AppLimits.addTimeSeconds,
      );

      final updated = await addMinute(timerId: timer.id!);

      expect(updated.remainingSeconds, AppLimits.maxDurationSeconds);
    });

    test('soma que passa do teto lança InvalidDurationException', () async {
      final timer = await insertTimer(
        status: TimerStatus.paused,
        remainingSeconds:
            AppLimits.maxDurationSeconds - AppLimits.addTimeSeconds + 1,
      );

      await expectLater(
        addMinute(timerId: timer.id!),
        throwsA(isA<InvalidDurationException>()),
      );

      final saved = await repository.getById(timer.id!);
      expect(saved!.remainingSeconds, timer.remainingSeconds);
    });
  });

  group('AddMinute - timer já disparado', () {
    test('volta a rodar com 60 segundos e agenda o alarme', () async {
      final timer = await insertTimer(status: TimerStatus.finished);

      final updated = await addMinute(timerId: timer.id!);

      expect(updated.status, TimerStatus.running);
      expect(updated.endsAt, fixedNow.add(const Duration(seconds: 60)));
      expect(updated.remainingSeconds, 60);
      expect(updated.finishedAt, isNull);
      expect(scheduler.scheduled[timer.notificationId], updated.endsAt);

      final saved = await repository.getById(timer.id!);
      expect(saved!.status, TimerStatus.running);
      expect(saved.finishedAt, isNull);
    });

    test(
      'com o limite de ativos atingido lança TooManyTimersException',
      () async {
        for (var i = 0; i < AppLimits.maxActiveTimers; i++) {
          await insertTimer(
            status: TimerStatus.running,
            endsIn: const Duration(seconds: 60),
          );
        }
        final finished = await insertTimer(status: TimerStatus.finished);

        await expectLater(
          addMinute(timerId: finished.id!),
          throwsA(isA<TooManyTimersException>()),
        );

        final saved = await repository.getById(finished.id!);
        expect(saved!.status, TimerStatus.finished);
        expect(scheduler.scheduled, isEmpty);
      },
    );
  });

  group('AddMinute - erros', () {
    test('timer parado lança InvalidTimerStateException', () async {
      final timer = await insertTimer(status: TimerStatus.stopped);

      await expectLater(
        addMinute(timerId: timer.id!),
        throwsA(isA<InvalidTimerStateException>()),
      );

      final saved = await repository.getById(timer.id!);
      expect(saved!.status, TimerStatus.stopped);
      expect(scheduler.scheduled, isEmpty);
    });

    test('id inexistente lança TimerNotFoundException', () async {
      await expectLater(
        addMinute(timerId: 999),
        throwsA(isA<TimerNotFoundException>()),
      );

      expect(scheduler.scheduled, isEmpty);
    });
  });
}
