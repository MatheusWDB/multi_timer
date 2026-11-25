import 'package:multi_timer/domain/usecases/add_minute.dart';
import 'package:multi_timer/domain/usecases/delete_timer.dart';
import 'package:multi_timer/domain/usecases/finish_timer.dart';
import 'package:multi_timer/domain/usecases/pause_timer.dart';
import 'package:multi_timer/domain/usecases/reconcile_timers.dart';
import 'package:multi_timer/domain/usecases/restart_timer.dart';
import 'package:multi_timer/domain/usecases/resume_timer.dart';
import 'package:multi_timer/domain/usecases/start_timer.dart';
import 'package:multi_timer/domain/usecases/stop_timer.dart';
import 'package:multi_timer/presentation/providers/dependency_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'usecase_providers.g.dart';

@Riverpod(keepAlive: true)
StartTimer startTimer(Ref ref) => StartTimer(
  repository: ref.watch(timerRepositoryProvider),
  scheduler: ref.watch(alarmSchedulerProvider),
  now: ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
PauseTimer pauseTimer(Ref ref) => PauseTimer(
  repository: ref.watch(timerRepositoryProvider),
  scheduler: ref.watch(alarmSchedulerProvider),
  now: ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
ResumeTimer resumeTimer(Ref ref) => ResumeTimer(
  repository: ref.watch(timerRepositoryProvider),
  scheduler: ref.watch(alarmSchedulerProvider),
  now: ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
AddMinute addMinute(Ref ref) => AddMinute(
  repository: ref.watch(timerRepositoryProvider),
  scheduler: ref.watch(alarmSchedulerProvider),
  now: ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
StopTimer stopTimer(Ref ref) => StopTimer(
  repository: ref.watch(timerRepositoryProvider),
  scheduler: ref.watch(alarmSchedulerProvider),
  now: ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
RestartTimer restartTimer(Ref ref) => RestartTimer(
  repository: ref.watch(timerRepositoryProvider),
  scheduler: ref.watch(alarmSchedulerProvider),
  now: ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
FinishTimer finishTimer(Ref ref) => FinishTimer(
  repository: ref.watch(timerRepositoryProvider),
  now: ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
DeleteTimer deleteTimer(Ref ref) => DeleteTimer(
  repository: ref.watch(timerRepositoryProvider),
  scheduler: ref.watch(alarmSchedulerProvider),
);

@Riverpod(keepAlive: true)
ReconcileTimers reconcileTimers(Ref ref) => ReconcileTimers(
  repository: ref.watch(timerRepositoryProvider),
  scheduler: ref.watch(alarmSchedulerProvider),
  now: ref.watch(clockProvider),
  finishTimer: ref.watch(finishTimerProvider),
);
