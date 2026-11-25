// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticker_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ticker)
final tickerProvider = TickerProvider._();

final class TickerProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, Stream<DateTime>>
    with $FutureModifier<DateTime>, $StreamProvider<DateTime> {
  TickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tickerHash();

  @$internal
  @override
  $StreamProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime> create(Ref ref) {
    return ticker(ref);
  }
}

String _$tickerHash() => r'74c0e3a0cef0d19ca7eebc4ca75c9f904006ea36';
