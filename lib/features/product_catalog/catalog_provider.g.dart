// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$catalogProductsHash() => r'b09fb8a8e684a82e71d5468fa0b2f2a1c203bf27';

/// See also [catalogProducts].
@ProviderFor(catalogProducts)
final catalogProductsProvider =
    AutoDisposeStreamProvider<List<ProductsTableData>>.internal(
  catalogProducts,
  name: r'catalogProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$catalogProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CatalogProductsRef
    = AutoDisposeStreamProviderRef<List<ProductsTableData>>;
String _$catalogSearchHash() => r'3724a599fcb3326428dee07edecae1d18000704a';

/// See also [CatalogSearch].
@ProviderFor(CatalogSearch)
final catalogSearchProvider =
    AutoDisposeNotifierProvider<CatalogSearch, String>.internal(
  CatalogSearch.new,
  name: r'catalogSearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$catalogSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CatalogSearch = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
