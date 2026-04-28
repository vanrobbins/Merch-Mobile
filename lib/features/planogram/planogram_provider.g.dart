// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planogram_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$planogramListHash() => r'3a019033ec82e87c2ef0c95c6115e1f9d9661e4f';

/// See also [planogramList].
@ProviderFor(planogramList)
final planogramListProvider =
    AutoDisposeStreamProvider<List<Planogram>>.internal(
  planogramList,
  name: r'planogramListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$planogramListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlanogramListRef = AutoDisposeStreamProviderRef<List<Planogram>>;
String _$planogramDetailHash() => r'19406ff419881ce037bf20462c76e0171ad73dc5';

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

/// See also [planogramDetail].
@ProviderFor(planogramDetail)
const planogramDetailProvider = PlanogramDetailFamily();

/// See also [planogramDetail].
class PlanogramDetailFamily extends Family<AsyncValue<Planogram?>> {
  /// See also [planogramDetail].
  const PlanogramDetailFamily();

  /// See also [planogramDetail].
  PlanogramDetailProvider call(
    String planogramId,
  ) {
    return PlanogramDetailProvider(
      planogramId,
    );
  }

  @override
  PlanogramDetailProvider getProviderOverride(
    covariant PlanogramDetailProvider provider,
  ) {
    return call(
      provider.planogramId,
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
  String? get name => r'planogramDetailProvider';
}

/// See also [planogramDetail].
class PlanogramDetailProvider extends AutoDisposeStreamProvider<Planogram?> {
  /// See also [planogramDetail].
  PlanogramDetailProvider(
    String planogramId,
  ) : this._internal(
          (ref) => planogramDetail(
            ref as PlanogramDetailRef,
            planogramId,
          ),
          from: planogramDetailProvider,
          name: r'planogramDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$planogramDetailHash,
          dependencies: PlanogramDetailFamily._dependencies,
          allTransitiveDependencies:
              PlanogramDetailFamily._allTransitiveDependencies,
          planogramId: planogramId,
        );

  PlanogramDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.planogramId,
  }) : super.internal();

  final String planogramId;

  @override
  Override overrideWith(
    Stream<Planogram?> Function(PlanogramDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlanogramDetailProvider._internal(
        (ref) => create(ref as PlanogramDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        planogramId: planogramId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Planogram?> createElement() {
    return _PlanogramDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanogramDetailProvider && other.planogramId == planogramId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, planogramId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlanogramDetailRef on AutoDisposeStreamProviderRef<Planogram?> {
  /// The parameter `planogramId` of this provider.
  String get planogramId;
}

class _PlanogramDetailProviderElement
    extends AutoDisposeStreamProviderElement<Planogram?>
    with PlanogramDetailRef {
  _PlanogramDetailProviderElement(super.provider);

  @override
  String get planogramId => (origin as PlanogramDetailProvider).planogramId;
}

String _$proposalListHash() => r'd4436a1cd4e6937a653457fcb1d4efcf78af00da';

/// See also [proposalList].
@ProviderFor(proposalList)
final proposalListProvider =
    AutoDisposeStreamProvider<List<PlanogramProposal>>.internal(
  proposalList,
  name: r'proposalListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$proposalListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProposalListRef = AutoDisposeStreamProviderRef<List<PlanogramProposal>>;
String _$planogramEditorHash() => r'7837c797e17bbbf1135582c1f6a4acc0d47af055';

abstract class _$PlanogramEditor
    extends BuildlessAutoDisposeNotifier<List<PgSlot>> {
  late final String planogramId;

  List<PgSlot> build(
    String planogramId,
  );
}

/// See also [PlanogramEditor].
@ProviderFor(PlanogramEditor)
const planogramEditorProvider = PlanogramEditorFamily();

/// See also [PlanogramEditor].
class PlanogramEditorFamily extends Family<List<PgSlot>> {
  /// See also [PlanogramEditor].
  const PlanogramEditorFamily();

  /// See also [PlanogramEditor].
  PlanogramEditorProvider call(
    String planogramId,
  ) {
    return PlanogramEditorProvider(
      planogramId,
    );
  }

  @override
  PlanogramEditorProvider getProviderOverride(
    covariant PlanogramEditorProvider provider,
  ) {
    return call(
      provider.planogramId,
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
  String? get name => r'planogramEditorProvider';
}

/// See also [PlanogramEditor].
class PlanogramEditorProvider
    extends AutoDisposeNotifierProviderImpl<PlanogramEditor, List<PgSlot>> {
  /// See also [PlanogramEditor].
  PlanogramEditorProvider(
    String planogramId,
  ) : this._internal(
          () => PlanogramEditor()..planogramId = planogramId,
          from: planogramEditorProvider,
          name: r'planogramEditorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$planogramEditorHash,
          dependencies: PlanogramEditorFamily._dependencies,
          allTransitiveDependencies:
              PlanogramEditorFamily._allTransitiveDependencies,
          planogramId: planogramId,
        );

  PlanogramEditorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.planogramId,
  }) : super.internal();

  final String planogramId;

  @override
  List<PgSlot> runNotifierBuild(
    covariant PlanogramEditor notifier,
  ) {
    return notifier.build(
      planogramId,
    );
  }

  @override
  Override overrideWith(PlanogramEditor Function() create) {
    return ProviderOverride(
      origin: this,
      override: PlanogramEditorProvider._internal(
        () => create()..planogramId = planogramId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        planogramId: planogramId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<PlanogramEditor, List<PgSlot>>
      createElement() {
    return _PlanogramEditorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanogramEditorProvider && other.planogramId == planogramId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, planogramId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlanogramEditorRef on AutoDisposeNotifierProviderRef<List<PgSlot>> {
  /// The parameter `planogramId` of this provider.
  String get planogramId;
}

class _PlanogramEditorProviderElement
    extends AutoDisposeNotifierProviderElement<PlanogramEditor, List<PgSlot>>
    with PlanogramEditorRef {
  _PlanogramEditorProviderElement(super.provider);

  @override
  String get planogramId => (origin as PlanogramEditorProvider).planogramId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
