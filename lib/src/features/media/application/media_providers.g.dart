// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mediaRepository)
final mediaRepositoryProvider = MediaRepositoryProvider._();

final class MediaRepositoryProvider
    extends
        $FunctionalProvider<MediaRepository, MediaRepository, MediaRepository>
    with $Provider<MediaRepository> {
  MediaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaRepositoryHash();

  @$internal
  @override
  $ProviderElement<MediaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaRepository create(Ref ref) {
    return mediaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaRepository>(value),
    );
  }
}

String _$mediaRepositoryHash() => r'79e923c49958d468c26d6a5fd6437424102ac342';

/// The app's base directory path, resolved once (for building image file paths).

@ProviderFor(appMediaBasePath)
final appMediaBasePathProvider = AppMediaBasePathProvider._();

/// The app's base directory path, resolved once (for building image file paths).

final class AppMediaBasePathProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The app's base directory path, resolved once (for building image file paths).
  AppMediaBasePathProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appMediaBasePathProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appMediaBasePathHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appMediaBasePath(ref);
  }
}

String _$appMediaBasePathHash() => r'cf4c84b4d60cc6a903b114706ee2e41f12f1bb0e';
