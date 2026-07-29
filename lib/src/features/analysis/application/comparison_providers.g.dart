// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comparison_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(comparisonRepository)
final comparisonRepositoryProvider = ComparisonRepositoryProvider._();

final class ComparisonRepositoryProvider
    extends
        $FunctionalProvider<
          ComparisonRepository,
          ComparisonRepository,
          ComparisonRepository
        >
    with $Provider<ComparisonRepository> {
  ComparisonRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'comparisonRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$comparisonRepositoryHash();

  @$internal
  @override
  $ProviderElement<ComparisonRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ComparisonRepository create(Ref ref) {
    return comparisonRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComparisonRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComparisonRepository>(value),
    );
  }
}

String _$comparisonRepositoryHash() =>
    r'b79362eea32e57b82f83d57bf0c54e79364d01a0';
