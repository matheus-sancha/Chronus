// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'studies_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studyRepository)
final studyRepositoryProvider = StudyRepositoryProvider._();

final class StudyRepositoryProvider
    extends
        $FunctionalProvider<StudyRepository, StudyRepository, StudyRepository>
    with $Provider<StudyRepository> {
  StudyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyRepositoryHash();

  @$internal
  @override
  $ProviderElement<StudyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StudyRepository create(Ref ref) {
    return studyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyRepository>(value),
    );
  }
}

String _$studyRepositoryHash() => r'2c92fe6806e4146b999b77c1d3a9898406fe1b41';

@ProviderFor(studyOperationRepository)
final studyOperationRepositoryProvider = StudyOperationRepositoryProvider._();

final class StudyOperationRepositoryProvider
    extends
        $FunctionalProvider<
          StudyOperationRepository,
          StudyOperationRepository,
          StudyOperationRepository
        >
    with $Provider<StudyOperationRepository> {
  StudyOperationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyOperationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyOperationRepositoryHash();

  @$internal
  @override
  $ProviderElement<StudyOperationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudyOperationRepository create(Ref ref) {
    return studyOperationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyOperationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyOperationRepository>(value),
    );
  }
}

String _$studyOperationRepositoryHash() =>
    r'b6e20ac792d58ece9c0c02ed30b8014acb57ab48';
