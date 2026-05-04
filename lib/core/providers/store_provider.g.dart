// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeStoreHash() => r'3d4e43a908d9a8897333746b64ec4f48103e67f7';

/// The full Store record for the active store ID.
///
/// Copied from [activeStore].
@ProviderFor(activeStore)
final activeStoreProvider = AutoDisposeStreamProvider<Store?>.internal(
  activeStore,
  name: r'activeStoreProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveStoreRef = AutoDisposeStreamProviderRef<Store?>;
String _$currentMembershipHash() => r'e14b16dca9a577be4e4b41b2cd84302f600a310b';

/// The current user's active membership in the active store.
///
/// Copied from [currentMembership].
@ProviderFor(currentMembership)
final currentMembershipProvider =
    AutoDisposeStreamProvider<StoreMembership?>.internal(
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
typedef CurrentMembershipRef = AutoDisposeStreamProviderRef<StoreMembership?>;
String _$myStoresHash() => r'2492e53b979ff569877b4ef2003495986ed5c0b0';

/// All stores where the current user has an active membership.
/// Primary source: /userStores/{uid} document (fast, no index needed).
/// Migration path: if that document is empty, falls back to a collection group
/// query and bootstraps the document so future loads skip it.
///
/// Copied from [myStores].
@ProviderFor(myStores)
final myStoresProvider = AutoDisposeStreamProvider<List<Store>>.internal(
  myStores,
  name: r'myStoresProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myStoresHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyStoresRef = AutoDisposeStreamProviderRef<List<Store>>;
String _$activeStoreIdHash() => r'1a7a9213c0ff78f46285b297137054be785071b9';

/// See also [ActiveStoreId].
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
