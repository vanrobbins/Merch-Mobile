// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeStoreHash() => r'8347bc22a0b7600fd2995372fd6c33a59554f134';

/// The full Store record for the active store ID.
///
/// Copied from [activeStore].
@ProviderFor(activeStore)
final activeStoreProvider =
    AutoDisposeStreamProvider<StoresTableData?>.internal(
  activeStore,
  name: r'activeStoreProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveStoreRef = AutoDisposeStreamProviderRef<StoresTableData?>;
String _$currentMembershipHash() => r'454229b3af2697c074ed4b60d094917a5934c495';

/// The current user's membership in the active store.
///
/// Copied from [currentMembership].
@ProviderFor(currentMembership)
final currentMembershipProvider =
    AutoDisposeStreamProvider<StoreMembershipsTableData?>.internal(
  currentMembership,
  name: r'currentMembershipProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentMembershipHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMembershipRef
    = AutoDisposeStreamProviderRef<StoreMembershipsTableData?>;
String _$myStoresHash() => r'20a12ecf815ddef6ae98c531021153a5e3834d03';

/// All stores the current user has an active membership in.
///
/// Copied from [myStores].
@ProviderFor(myStores)
final myStoresProvider =
    AutoDisposeStreamProvider<List<StoresTableData>>.internal(
  myStores,
  name: r'myStoresProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myStoresHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyStoresRef = AutoDisposeStreamProviderRef<List<StoresTableData>>;
String _$activeStoreIdHash() => r'1a7a9213c0ff78f46285b297137054be785071b9';

/// The currently selected store ID. Persisted across launches.
///
/// Copied from [ActiveStoreId].
@ProviderFor(ActiveStoreId)
final activeStoreIdProvider =
    AsyncNotifierProvider<ActiveStoreId, String?>.internal(
  ActiveStoreId.new,
  name: r'activeStoreIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeStoreIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveStoreId = AsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
