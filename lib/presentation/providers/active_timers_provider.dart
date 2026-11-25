import 'package:multi_timer/domain/entities/timer.dart';
import 'package:multi_timer/presentation/providers/dependency_providers.dart';
import 'package:multi_timer/presentation/providers/history_provider.dart';
import 'package:multi_timer/presentation/providers/usecase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_timers_provider.g.dart';

@Riverpod(keepAlive: true)
class ActiveTimers extends _$ActiveTimers {
  @override
  Future<List<TimerEntity>> build() async {
    await ref.read(reconcileTimersProvider)();

    return ref.read(timerRepositoryProvider).getActiveTimers();
  }

  Future<void> start({
    required int durationSeconds,
    required int color,
    required String soundId,
    String? name,
    int? presetId,
  }) async {
    await ref.read(startTimerProvider)(
      durationSeconds: durationSeconds,
      color: color,
      soundId: soundId,
      name: name,
      presetId: presetId,
    );
    await _reload();
  }

  Future<void> pause(int timerId) async {
    await ref.read(pauseTimerProvider)(timerId: timerId);
    await _reload();
  }

  Future<void> resume(int timerId) async {
    await ref.read(resumeTimerProvider)(timerId: timerId);
    await _reload();
  }

  Future<void> addMinute(int timerId) async {
    await ref.read(addMinuteProvider)(timerId: timerId);
    await _reload();
  }

  Future<void> stop(int timerId) async {
    await ref.read(stopTimerProvider)(timerId: timerId);
    await _reload();
  }

  Future<void> restart(int timerId) async {
    await ref.read(restartTimerProvider)(timerId: timerId);
    await _reload();
  }

  Future<void> finish(int timerId) async {
    await ref.read(finishTimerProvider)(timerId: timerId);
    await _reload();
  }

  Future<void> remove(int timerId) async {
    await ref.read(deleteTimerProvider)(timerId: timerId);
    await _reload();
  }

  Future<void> _reload() async {
    state = AsyncData(
      await ref.read(timerRepositoryProvider).getActiveTimers(),
    );
    
    ref.invalidate(historyProvider);
  }
}
