// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$catalogProductsHash() => r'9b3438556cafe6e925d9bd3516606183ba9196a4';

/// See also [catalogProducts].
@ProviderFor(catalogProducts)
final catalogProductsProvider =
    AutoDisposeStreamProvider<List<Product>>.internal(
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
typedef CatalogProductsRef = AutoDisposeStreamProviderRef<List<Product>>;
String _$brandColorsHash() => r'92f181c1a88b0ad7930a39662672381d1cf5456c';

/// See also [brandColors].
@ProviderFor(brandColors)
final brandColorsProvider =
    AutoDisposeStreamProvider<List<BrandColor>>.internal(
  brandColors,
  name: r'brandColorsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$brandColorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BrandColorsRef = AutoDisposeStreamProviderRef<List<BrandColor>>;
String _$productTemplatesHash() => r'a6d4a1d651a863148cd7319f083cb49a3edc8849';

/// See also [productTemplates].
@ProviderFor(productTemplates)
final productTemplatesProvider =
    AutoDisposeStreamProvider<List<ProductTemplate>>.internal(
  productTemplates,
  name: r'productTemplatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productTemplatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductTemplatesRef
    = AutoDisposeStreamProviderRef<List<ProductTemplate>>;
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
