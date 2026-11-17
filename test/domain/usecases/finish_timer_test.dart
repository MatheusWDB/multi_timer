import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/usecases/finish_timer.dart';

import '../fakes/fake_timer_repository.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);
  final finishedBefore = fixedNow.subtract(const Duration(minutes: 5));

  late FakeTimerRepository repository;
  late FinishTimer finishTimer;

  setUp(() {
    repository = FakeTimerRepository();
    finishTimer = FinishTimer(repository: repository, now: () => fixedNow);
  });

  Future<TimerEntity> insertTimer({
    required TimerStatus status,
    Duration? endsIn,
  }) {
    final isClosed =
        status == TimerStatus.finished || status == TimerStatus.stopped;

    return repository.insert(
      TimerEntity(
        name: 'Timer 1',
        soundId: 'default',
        color: 0xFF000000,
        durationSeconds: 60,
        remainingSeconds: 60,
        notificationId: 123,
        createdAt: fixedNow,
        status: status,
        endsAt: endsIn == null ? null : fixedNow.add(endsIn),
        finishedAt: isClosed ? finishedBefore : null,
      ),
    );
  }

  group('FinishTimer - fluxo normal', () {
    test(
      'timer vencido vira finished com finishedAt = endsAt original',
      () async {
        final timer = await insertTimer(
          status: TimerStatus.running,
          endsIn: const Duration(seconds: -30),
        );

        final finished = await finishTimer(timerId: timer.id!);

        expect(finished.status, TimerStatus.finished);
        expect(finished.endsAt, isNull);
        expect(finished.finishedAt, timer.endsAt);

        final saved = await repository.getById(timer.id!);
        expect(saved!.status, TimerStatus.finished);
        expect(saved.endsAt, isNull);
        expect(saved.finishedAt, timer.endsAt);
      },
    );
  });

  group('FinishTimer - bordas', () {
    test('endsAt exatamente igual a agora finaliza o timer', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: Duration.zero,
      );

      final finished = await finishTimer(timerId: timer.id!);

      expect(finished.status, TimerStatus.finished);
      expect(finished.finishedAt, fixedNow);
    });

    test('endsAt ainda no futuro é ignorado', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: 1),
      );

      final result = await finishTimer(timerId: timer.id!);

      expect(result.status, TimerStatus.running);
      expect(result.endsAt, timer.endsAt);

      final saved = await repository.getById(timer.id!);
      expect(saved!.status, TimerStatus.running);
      expect(saved.endsAt, timer.endsAt);
      expect(saved.finishedAt, isNull);
    });
  });

  group('FinishTimer - timers que não estão em andamento', () {
    for (final status in [
      TimerStatus.paused,
      TimerStatus.finished,
      TimerStatus.stopped,
    ]) {
      test('timer ${status.name} é devolvido sem alterações', () async {
        final timer = await insertTimer(status: status);

        final result = await finishTimer(timerId: timer.id!);

        expect(result.status, status);
        expect(result.finishedAt, timer.finishedAt);

        final saved = await repository.getById(timer.id!);
        expect(saved!.status, status);
        expect(saved.finishedAt, timer.finishedAt);
      });
    }
  });

  group('FinishTimer - erros', () {
    test('id inexistente lança TimerNotFoundException', () async {
      await expectLater(
        finishTimer(timerId: 999),
        throwsA(isA<TimerNotFoundException>()),
      );
    });
  });
}
