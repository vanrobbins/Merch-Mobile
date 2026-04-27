// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_detail_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$zoneDetailZonesHash() => r'89b6c7c882cac40b0624f0c00e97cb2ad57c7eee';

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

/// See also [zoneDetailZones].
@ProviderFor(zoneDetailZones)
const zoneDetailZonesProvider = ZoneDetailZonesFamily();

/// See also [zoneDetailZones].
class ZoneDetailZonesFamily extends Family<AsyncValue<List<ZonesTableData>>> {
  /// See also [zoneDetailZones].
  const ZoneDetailZonesFamily();

  /// See also [zoneDetailZones].
  ZoneDetailZonesProvider call(
    String storeId,
  ) {
    return ZoneDetailZonesProvider(
      storeId,
    );
  }

  @override
  ZoneDetailZonesProvider getProviderOverride(
    covariant ZoneDetailZonesProvider provider,
  ) {
    return call(
      provider.storeId,
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
  String? get name => r'zoneDetailZonesProvider';
}

/// See also [zoneDetailZones].
class ZoneDetailZonesProvider
    extends AutoDisposeStreamProvider<List<ZonesTableData>> {
  /// See also [zoneDetailZones].
  ZoneDetailZonesProvider(
    String storeId,
  ) : this._internal(
          (ref) => zoneDetailZones(
            ref as ZoneDetailZonesRef,
            storeId,
          ),
          from: zoneDetailZonesProvider,
          name: r'zoneDetailZonesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$zoneDetailZonesHash,
          dependencies: ZoneDetailZonesFamily._dependencies,
          allTransitiveDependencies:
              ZoneDetailZonesFamily._allTransitiveDependencies,
          storeId: storeId,
        );

  ZoneDetailZonesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.storeId,
  }) : super.internal();

  final String storeId;

  @override
  Override overrideWith(
    Stream<List<ZonesTableData>> Function(ZoneDetailZonesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ZoneDetailZonesProvider._internal(
        (ref) => create(ref as ZoneDetailZonesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        storeId: storeId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ZonesTableData>> createElement() {
    return _ZoneDetailZonesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ZoneDetailZonesProvider && other.storeId == storeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ZoneDetailZonesRef on AutoDisposeStreamProviderRef<List<ZonesTableData>> {
  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _ZoneDetailZonesProviderElement
    extends AutoDisposeStreamProviderElement<List<ZonesTableData>>
    with ZoneDetailZonesRef {
  _ZoneDetailZonesProviderElement(super.provider);

  @override
  String get storeId => (origin as ZoneDetailZonesProvider).storeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
