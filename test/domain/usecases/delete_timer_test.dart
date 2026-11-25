import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/domain/exceptions/timer_exceptions.dart';
import 'package:multi_timer/domain/usecases/delete_timer.dart';

import '../fakes/fake_alarm_scheduler.dart';
import '../fakes/fake_timer_repository.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);
  const notificationId = 123;

  late FakeTimerRepository repository;
  late FakeAlarmScheduler scheduler;
  late DeleteTimer deleteTimer;

  setUp(() {
    repository = FakeTimerRepository();
    scheduler = FakeAlarmScheduler();
    deleteTimer = DeleteTimer(repository: repository, scheduler: scheduler);
  });

  Future<TimerEntity> insertTimer({
    required TimerStatus status,
    int id = notificationId,
    Duration? endsIn,
  }) {
    final isClosed =
        status == TimerStatus.finished || status == TimerStatus.stopped;

    return repository.insert(
      TimerEntity(
        name: 'Timer $id',
        soundId: 'default',
        color: 0xFF000000,
        durationSeconds: 60,
        remainingSeconds: 60,
        notificationId: id,
        createdAt: fixedNow,
        status: status,
        endsAt: endsIn == null ? null : fixedNow.add(endsIn),
        finishedAt: isClosed ? fixedNow : null,
      ),
    );
  }

  group('DeleteTimer - timer em andamento', () {
    test('exclui o timer e cancela o alarme', () async {
      final timer = await insertTimer(
        status: TimerStatus.running,
        endsIn: const Duration(seconds: 90),
      );
      scheduler.scheduled[timer.notificationId] = timer.endsAt!;

      await deleteTimer(timerId: timer.id!);

      expect(await repository.getById(timer.id!), isNull);
      expect(scheduler.scheduled, isEmpty);
      expect(scheduler.cancelled, [timer.notificationId]);
    });
  });

  group('DeleteTimer - timers sem alarme', () {
    for (final status in [
      TimerStatus.paused,
      TimerStatus.finished,
      TimerStatus.stopped,
    ]) {
      test('exclui o timer ${status.name} sem cancelar alarme', () async {
        final timer = await insertTimer(status: status);

        await deleteTimer(timerId: timer.id!);

        expect(await repository.getById(timer.id!), isNull);
        expect(scheduler.cancelled, isEmpty);
      });
    }
  });

  group('DeleteTimer - isolamento', () {
    test('não afeta os outros timers nem os alarmes deles', () async {
      final target = await insertTimer(
        status: TimerStatus.running,
        id: 1,
        endsIn: const Duration(seconds: 60),
      );
      final other = await insertTimer(
        status: TimerStatus.running,
        id: 2,
        endsIn: const Duration(seconds: 120),
      );
      scheduler.scheduled[target.notificationId] = target.endsAt!;
      scheduler.scheduled[other.notificationId] = other.endsAt!;

      await deleteTimer(timerId: target.id!);

      expect(await repository.getById(other.id!), isNotNull);
      expect(scheduler.scheduled.keys, [other.notificationId]);
      expect(scheduler.cancelled, [target.notificationId]);
    });
  });

  group('DeleteTimer - erros', () {
    test('id inexistente lança TimerNotFoundException', () async {
      await expectLater(
        deleteTimer(timerId: 999),
        throwsA(isA<TimerNotFoundException>()),
      );

      expect(scheduler.cancelled, isEmpty);
    });
  });
}
