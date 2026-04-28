// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeStoreHash() => r'd3e90b133496e431fcd1e7a0c97a4bae00e96c0c';

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
String _$currentMembershipHash() => r'e06b07a67a365fe650bb891610ea9faf0e24758a';

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
String _$myStoresHash() => r'cf55ceedffae2fb4071f707130ad3e362417b928';

/// All stores where the current user has an active membership.
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
