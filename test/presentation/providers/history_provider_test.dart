import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/domain/entities/timer_status.dart';
import 'package:multi_timer/presentation/providers/dependency_providers.dart';
import 'package:multi_timer/presentation/providers/history_provider.dart';

import '../../domain/fakes/fake_timer_repository.dart';

void main() {
  final base = DateTime(2026, 1, 1, 12, 0, 0);

  late FakeTimerRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeTimerRepository();
    container = ProviderContainer(
      overrides: [timerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  // Só começa a observar o histórico depois que os dados já foram inseridos.
  Future<List<TimerEntity>> loadHistory() {
    container.listen(historyProvider, (previous, next) {});
    return container.read(historyProvider.future);
  }

  Future<TimerEntity> insertTimer({
    required TimerStatus status,
    int minutesAfterBase = 0,
  }) {
    final isClosed =
        status == TimerStatus.finished || status == TimerStatus.stopped;

    return repository.insert(
      TimerEntity(
        name: 'Timer',
        soundId: 'default',
        color: 0xFF000000,
        durationSeconds: 60,
        remainingSeconds: 60,
        notificationId: 1,
        createdAt: base,
        status: status,
        endsAt: status == TimerStatus.running
            ? base.add(const Duration(minutes: 10))
            : null,
        finishedAt: isClosed
            ? base.add(Duration(minutes: minutesAfterBase))
            : null,
      ),
    );
  }

  group('build', () {
    test(
      'devolve só os encerrados, do mais recente para o mais antigo',
      () async {
        final first = await insertTimer(
          status: TimerStatus.finished,
          minutesAfterBase: 1,
        );
        final second = await insertTimer(
          status: TimerStatus.stopped,
          minutesAfterBase: 5,
        );
        await insertTimer(status: TimerStatus.running);
        await insertTimer(status: TimerStatus.paused);

        final history = await loadHistory();

        expect(history.map((timer) => timer.id), [second.id, first.id]);
      },
    );
  });

  group('clear', () {
    test('apaga o histórico e mantém os timers ativos', () async {
      await insertTimer(status: TimerStatus.finished, minutesAfterBase: 1);
      await insertTimer(status: TimerStatus.stopped, minutesAfterBase: 2);
      await insertTimer(status: TimerStatus.running);
      final before = await loadHistory();
      expect(before, hasLength(2));

      await container.read(historyProvider.notifier).clear();

      expect(container.read(historyProvider).requireValue, isEmpty);
      expect(repository.timers, hasLength(1));
      expect(repository.timers.single.status, TimerStatus.running);
    });
  });
}
