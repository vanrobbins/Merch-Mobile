// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floor_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$zoneByIdHash() => r'fb164a331ae69b85666fb3b84f74474a50dea1a2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [zoneById].
@ProviderFor(zoneById)
const zoneByIdProvider = ZoneByIdFamily();

/// See also [zoneById].
class ZoneByIdFamily extends Family<AsyncValue<StoreZone?>> {
  /// See also [zoneById].
  const ZoneByIdFamily();

  /// See also [zoneById].
  ZoneByIdProvider call(
    String zoneId,
  ) {
    return ZoneByIdProvider(
      zoneId,
    );
  }

  @override
  ZoneByIdProvider getProviderOverride(
    covariant ZoneByIdProvider provider,
  ) {
    return call(
      provider.zoneId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'zoneByIdProvider';
}

/// See also [zoneById].
class ZoneByIdProvider extends AutoDisposeStreamProvider<StoreZone?> {
  /// See also [zoneById].
  ZoneByIdProvider(
    String zoneId,
  ) : this._internal(
          (ref) => zoneById(
            ref as ZoneByIdRef,
            zoneId,
          ),
          from: zoneByIdProvider,
          name: r'zoneByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$zoneByIdHash,
          dependencies: ZoneByIdFamily._dependencies,
          allTransitiveDependencies: ZoneByIdFamily._allTransitiveDependencies,
          zoneId: zoneId,
        );

  ZoneByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.zoneId,
  }) : super.internal();

  final String zoneId;

  @override
  Override overrideWith(
    Stream<StoreZone?> Function(ZoneByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ZoneByIdProvider._internal(
        (ref) => create(ref as ZoneByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        zoneId: zoneId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<StoreZone?> createElement() {
    return _ZoneByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ZoneByIdProvider && other.zoneId == zoneId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, zoneId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ZoneByIdRef on AutoDisposeStreamProviderRef<StoreZone?> {
  /// The parameter `zoneId` of this provider.
  String get zoneId;
}

class _ZoneByIdProviderElement
    extends AutoDisposeStreamProviderElement<StoreZone?> with ZoneByIdRef {
  _ZoneByIdProviderElement(super.provider);

  @override
  String get zoneId => (origin as ZoneByIdProvider).zoneId;
}

String _$floorBuilderNotifierHash() =>
    r'3894adc9fa64797c690c4e40d9b92b2b32512ca3';

/// See also [FloorBuilderNotifier].
@ProviderFor(FloorBuilderNotifier)
final floorBuilderNotifierProvider = AutoDisposeNotifierProvider<
    FloorBuilderNotifier, FloorBuilderState>.internal(
  FloorBuilderNotifier.new,
  name: r'floorBuilderNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$floorBuilderNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FloorBuilderNotifier = AutoDisposeNotifier<FloorBuilderState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
