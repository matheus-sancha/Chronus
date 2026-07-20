// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'templates_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(templateRepository)
final templateRepositoryProvider = TemplateRepositoryProvider._();

final class TemplateRepositoryProvider
    extends
        $FunctionalProvider<
          TemplateRepository,
          TemplateRepository,
          TemplateRepository
        >
    with $Provider<TemplateRepository> {
  TemplateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'templateRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$templateRepositoryHash();

  @$internal
  @override
  $ProviderElement<TemplateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TemplateRepository create(Ref ref) {
    return templateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TemplateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TemplateRepository>(value),
    );
  }
}

String _$templateRepositoryHash() =>
    r'760548d03cb3d8092879790144263043ded7fca3';
