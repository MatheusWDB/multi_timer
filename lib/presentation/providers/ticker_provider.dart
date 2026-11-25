import 'package:multi_timer/presentation/providers/dependency_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ticker_provider.g.dart';

@riverpod
Stream<DateTime> ticker(Ref ref) async* {
  final clock = ref.watch(clockProvider);
  
  yield clock();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => clock());
}
