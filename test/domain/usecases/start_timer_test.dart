import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/core/constants/app_limits.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/usecases/start_timer.dart';

import '../fakes/fake_alarm_scheduler.dart';
import '../fakes/fake_timer_repository.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);

  late FakeTimerRepository repository;
  late FakeAlarmScheduler scheduler;
  late StartTimer startTimer;

  setUp(() {
    repository = FakeTimerRepository();
    scheduler = FakeAlarmScheduler();
    startTimer = StartTimer(
      repository: repository,
      scheduler: scheduler,
      now: () => fixedNow,
    );
  });

  TimerEntity buildActiveTimer(int index) {
    return TimerEntity(
      name: 'Timer $index',
      soundId: 'default',
      color: 0xFF000000,
      durationSeconds: 60,
      remainingSeconds: 60,
      notificationId: index,
      createdAt: fixedNow,
      status: TimerStatus.running,
      endsAt: fixedNow.add(const Duration(seconds: 60)),
    );
  }

  group('StartTimer - criação', () {
    test('cria timer em andamento com endsAt = agora + duração', () async {
      final timer = await startTimer(
        durationSeconds: 300,
        color: 0xFF2196F3,
        soundId: 'default',
      );

      expect(timer.id, isNotNull);
      expect(timer.status, TimerStatus.running);
      expect(timer.remainingSeconds, 300);
      expect(timer.endsAt, fixedNow.add(const Duration(seconds: 300)));
      expect(repository.timers, hasLength(1));
    });

    test('mantém o presetId informado', () async {
      final timer = await startTimer(
        durationSeconds: 60,
        color: 0xFF2196F3,
        soundId: 'default',
        presetId: 7,
      );

      expect(timer.presetId, 7);
    });

    test('gera notificationId que cabe em 32 bits', () async {
      final timer = await startTimer(
        durationSeconds: 60,
        color: 0xFF2196F3,
        soundId: 'default',
      );

      expect(timer.notificationId, greaterThanOrEqualTo(0));
      expect(timer.notificationId, lessThan(2147483648));
    });
  });

  group('StartTimer - alarme', () {
    test('agenda o alarme com o notificationId e o endsAt do timer', () async {
      final timer = await startTimer(
        durationSeconds: 120,
        color: 0xFF2196F3,
        soundId: 'default',
      );

      expect(scheduler.scheduled[timer.notificationId], timer.endsAt);
    });
  });

  group('StartTimer - nome', () {
    test('nome nulo vira "Timer N" (ativos + 1)', () async {
      final timer = await startTimer(
        durationSeconds: 60,
        color: 0xFF2196F3,
        soundId: 'default',
      );

      expect(timer.name, 'Timer 1');
    });

    test('nome só com espaços vira "Timer N" considerando os ativos', () async {
      repository.timers.addAll([buildActiveTimer(1), buildActiveTimer(2)]);

      final timer = await startTimer(
        durationSeconds: 60,
        color: 0xFF2196F3,
        soundId: 'default',
        name: '   ',
      );

      expect(timer.name, 'Timer 3');
    });

    test('remove espaços das pontas do nome informado', () async {
      final timer = await startTimer(
        durationSeconds: 60,
        color: 0xFF2196F3,
        soundId: 'default',
        name: '  Macarrão  ',
      );

      expect(timer.name, 'Macarrão');
    });
  });

  group('StartTimer - validações', () {
    test('duração abaixo do mínimo lança InvalidDurationException', () async {
      await expectLater(
        startTimer(
          durationSeconds: AppLimits.minDurationSeconds - 1,
          color: 0xFF2196F3,
          soundId: 'default',
        ),
        throwsA(isA<InvalidDurationException>()),
      );

      expect(repository.timers, isEmpty);
      expect(scheduler.scheduled, isEmpty);
    });

    test('duração acima do máximo lança InvalidDurationException', () async {
      await expectLater(
        startTimer(
          durationSeconds: AppLimits.maxDurationSeconds + 1,
          color: 0xFF2196F3,
          soundId: 'default',
        ),
        throwsA(isA<InvalidDurationException>()),
      );

      expect(repository.timers, isEmpty);
    });

    test('aceita as durações mínima e máxima', () async {
      final min = await startTimer(
        durationSeconds: AppLimits.minDurationSeconds,
        color: 0xFF2196F3,
        soundId: 'default',
      );
      final max = await startTimer(
        durationSeconds: AppLimits.maxDurationSeconds,
        color: 0xFF2196F3,
        soundId: 'default',
      );

      expect(min.durationSeconds, AppLimits.minDurationSeconds);
      expect(max.durationSeconds, AppLimits.maxDurationSeconds);
    });

    test(
      'com o limite de ativos atingido lança TooManyTimersException',
      () async {
        repository.timers.addAll(
          List.generate(AppLimits.maxActiveTimers, buildActiveTimer),
        );

        await expectLater(
          startTimer(
            durationSeconds: 60,
            color: 0xFF2196F3,
            soundId: 'default',
          ),
          throwsA(isA<TooManyTimersException>()),
        );

        expect(repository.timers, hasLength(AppLimits.maxActiveTimers));
        expect(scheduler.scheduled, isEmpty);
      },
    );

    test('timers pausados também contam no limite de ativos', () async {
      repository.timers.addAll(
        List.generate(
          AppLimits.maxActiveTimers,
          (index) =>
              buildActiveTimer(index).copyWith(status: TimerStatus.paused),
        ),
      );

      await expectLater(
        startTimer(durationSeconds: 60, color: 0xFF2196F3, soundId: 'default'),
        throwsA(isA<TooManyTimersException>()),
      );
    });
  });
}
