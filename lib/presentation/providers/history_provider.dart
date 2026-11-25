import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/presentation/providers/dependency_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_provider.g.dart';

@riverpod
class History extends _$History {
  @override
  Future<List<TimerEntity>> build() async {
    return ref.watch(timerRepositoryProvider).getHistoryTimers();
  }

  Future<void> clear() async {
    final repository = ref.read(timerRepositoryProvider);

    await repository.clearHistory();

    state = AsyncData(await repository.getHistoryTimers());
  }
}
