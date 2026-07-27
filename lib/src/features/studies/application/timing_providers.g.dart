// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(timingRepository)
final timingRepositoryProvider = TimingRepositoryProvider._();

final class TimingRepositoryProvider
    extends
        $FunctionalProvider<
          TimingRepository,
          TimingRepository,
          TimingRepository
        >
    with $Provider<TimingRepository> {
  TimingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timingRepositoryHash();

  @$internal
  @override
  $ProviderElement<TimingRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TimingRepository create(Ref ref) {
    return timingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimingRepository>(value),
    );
  }
}

String _$timingRepositoryHash() => r'479550e6c4769ac98c1a6d45a41c8ff46db416d6';

@ProviderFor(observationRepository)
final observationRepositoryProvider = ObservationRepositoryProvider._();

final class ObservationRepositoryProvider
    extends
        $FunctionalProvider<
          ObservationRepository,
          ObservationRepository,
          ObservationRepository
        >
    with $Provider<ObservationRepository> {
  ObservationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'observationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$observationRepositoryHash();

  @$internal
  @override
  $ProviderElement<ObservationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ObservationRepository create(Ref ref) {
    return observationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ObservationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ObservationRepository>(value),
    );
  }
}

String _$observationRepositoryHash() =>
    r'48c9601a73ddee94fa1ccb6f57a7224bcf90a625';
