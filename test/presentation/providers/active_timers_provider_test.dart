import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/core/constants/app_limits.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/presentation/providers/active_timers_provider.dart';
import 'package:multi_timer/presentation/providers/dependency_providers.dart';
import 'package:multi_timer/presentation/providers/history_provider.dart';

import '../../domain/fakes/fake_alarm_scheduler.dart';
import '../../domain/fakes/fake_timer_repository.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);

  late DateTime currentNow;
  late FakeTimerRepository repository;
  late FakeAlarmScheduler scheduler;
  late ProviderContainer container;

  setUp(() {
    currentNow = fixedNow;
    repository = FakeTimerRepository();
    scheduler = FakeAlarmScheduler();
    container = ProviderContainer(
      overrides: [
        timerRepositoryProvider.overrideWithValue(repository),
        alarmSchedulerProvider.overrideWithValue(scheduler),
        clockProvider.overrideWithValue(() => currentNow),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<TimerEntity> insertTimer({
    required TimerStatus status,
    required int notificationId,
    Duration? endsIn,
    int durationSeconds = 60,
    int remainingSeconds = 60,
  }) {
    final isClosed =
        status == TimerStatus.finished || status == TimerStatus.stopped;

    return repository.insert(
      TimerEntity(
        name: 'Timer $notificationId',
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

  Future<List<TimerEntity>> loadActive() {
    return container.read(activeTimersProvider.future);
  }

  ActiveTimers notifier() => container.read(activeTimersProvider.notifier);

  List<TimerEntity> activeState() {
    return container.read(activeTimersProvider).requireValue;
  }

  group('build - ao abrir o app', () {
    test(
      'reconcilia: vencido sai da lista e futuro continua com alarme',
      () async {
        final expired = await insertTimer(
          status: TimerStatus.running,
          notificationId: 1,
          endsIn: const Duration(minutes: -5),
        );
        final upcoming = await insertTimer(
          status: TimerStatus.running,
          notificationId: 2,
          endsIn: const Duration(minutes: 10),
        );

        final active = await loadActive();

        expect(active.map((timer) => timer.id), [upcoming.id]);
        expect(scheduler.scheduled[2], upcoming.endsAt);

        final savedExpired = await repository.getById(expired.id!);
        expect(savedExpired!.status, TimerStatus.finished);
      },
    );

    test('sem timers devolve lista vazia', () async {
      final active = await loadActive();

      expect(active, isEmpty);
    });
  });

  group('start', () {
    test('adiciona o timer à lista e agenda o alarme', () async {
      await loadActive();

      await notifier().start(
        durationSeconds: 300,
        color: 0xFF2196F3,
        soundId: 'default',
      );

      expect(activeState(), hasLength(1));
      expect(activeState().first.name, 'Timer 1');
      expect(activeState().first.status, TimerStatus.running);
      expect(scheduler.scheduled, hasLength(1));
    });

    test('duração inválida lança exceção e a lista continua intacta', () async {
      await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: const Duration(minutes: 5),
      );
      await loadActive();

      await expectLater(
        notifier().start(
          durationSeconds: 0,
          color: 0xFF2196F3,
          soundId: 'default',
        ),
        throwsA(isA<InvalidDurationException>()),
      );

      expect(container.read(activeTimersProvider).hasValue, isTrue);
      expect(activeState(), hasLength(1));
    });

    test('com o limite de ativos lança exceção e mantém a lista', () async {
      for (var i = 1; i <= AppLimits.maxActiveTimers; i++) {
        await insertTimer(
          status: TimerStatus.running,
          notificationId: i,
          endsIn: const Duration(minutes: 5),
        );
      }
      await loadActive();

      await expectLater(
        notifier().start(
          durationSeconds: 60,
          color: 0xFF2196F3,
          soundId: 'default',
        ),
        throwsA(isA<TooManyTimersException>()),
      );

      expect(activeState(), hasLength(AppLimits.maxActiveTimers));
    });
  });

  group('pause e resume', () {
    test('pause atualiza o timer da lista para pausado', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: const Duration(seconds: 90),
      );
      await loadActive();

      await notifier().pause(timer.id!);

      expect(activeState().single.status, TimerStatus.paused);
      expect(activeState().single.remainingSeconds, 90);
      expect(activeState().single.endsAt, isNull);
    });

    test('resume atualiza o timer da lista para em andamento', () async {
      final timer = await insertTimer(
        status: TimerStatus.paused,
        notificationId: 1,
        remainingSeconds: 90,
      );
      await loadActive();

      await notifier().resume(timer.id!);

      expect(activeState().single.status, TimerStatus.running);
      expect(
        activeState().single.endsAt,
        fixedNow.add(const Duration(seconds: 90)),
      );
    });
  });

  group('addMinute', () {
    test('soma 60 segundos ao endsAt do timer na lista', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: const Duration(seconds: 90),
      );
      await loadActive();

      await notifier().addMinute(timer.id!);

      expect(
        activeState().single.endsAt,
        fixedNow.add(const Duration(seconds: 150)),
      );
    });
  });

  group('stop e finish', () {
    test('stop tira o timer da lista e ele aparece no histórico', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: const Duration(minutes: 5),
      );
      container.listen(historyProvider, (previous, next) {});
      await loadActive();
      await container.read(historyProvider.future);

      await notifier().stop(timer.id!);

      expect(activeState(), isEmpty);
      final history = await container.read(historyProvider.future);
      expect(history.map((item) => item.id), [timer.id]);
      expect(history.single.status, TimerStatus.stopped);
    });

    test(
      'finish tira o timer vencido da lista e vai para o histórico',
      () async {
        final timer = await insertTimer(
          status: TimerStatus.running,
          notificationId: 1,
          endsIn: const Duration(seconds: 30),
        );
        container.listen(historyProvider, (previous, next) {});
        await loadActive();
        await container.read(historyProvider.future);

        currentNow = fixedNow.add(const Duration(minutes: 1));
        await notifier().finish(timer.id!);

        expect(activeState(), isEmpty);
        final history = await container.read(historyProvider.future);
        expect(history.single.status, TimerStatus.finished);
      },
    );
  });

  group('restart e remove', () {
    test('restart volta o timer ao tempo total', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: const Duration(seconds: 30),
        durationSeconds: 120,
      );
      await loadActive();

      await notifier().restart(timer.id!);

      expect(
        activeState().single.endsAt,
        fixedNow.add(const Duration(seconds: 120)),
      );
    });

    test('remove tira o timer da lista e cancela o alarme', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: const Duration(minutes: 5),
      );
      await loadActive();

      await notifier().remove(timer.id!);

      expect(activeState(), isEmpty);
      expect(scheduler.cancelled, [timer.notificationId]);
    });
  });

  group('erros', () {
    test('id inexistente lança exceção e a lista continua intacta', () async {
      await insertTimer(
        status: TimerStatus.running,
        notificationId: 1,
        endsIn: const Duration(minutes: 5),
      );
      await loadActive();

      await expectLater(
        notifier().pause(999),
        throwsA(isA<TimerNotFoundException>()),
      );

      expect(container.read(activeTimersProvider).hasValue, isTrue);
      expect(activeState(), hasLength(1));
    });
  });
}
