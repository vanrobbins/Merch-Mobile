// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planogram_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$planogramListHash() => r'32cf1b1acaef7d297415740e0c847ac51a8c0099';

/// All planograms for the currently active store.
///
/// Copied from [planogramList].
@ProviderFor(planogramList)
final planogramListProvider =
    AutoDisposeStreamProvider<List<PlanogramsTableData>>.internal(
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
typedef PlanogramListRef
    = AutoDisposeStreamProviderRef<List<PlanogramsTableData>>;
String _$planogramDetailHash() => r'2220c92744b49b9153c005fe2d36929083a83baa';

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

/// A single planogram by id, reactive to DB changes.
///
/// Copied from [planogramDetail].
@ProviderFor(planogramDetail)
const planogramDetailProvider = PlanogramDetailFamily();

/// A single planogram by id, reactive to DB changes.
///
/// Copied from [planogramDetail].
class PlanogramDetailFamily extends Family<AsyncValue<PlanogramsTableData?>> {
  /// A single planogram by id, reactive to DB changes.
  ///
  /// Copied from [planogramDetail].
  const PlanogramDetailFamily();

  /// A single planogram by id, reactive to DB changes.
  ///
  /// Copied from [planogramDetail].
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

/// A single planogram by id, reactive to DB changes.
///
/// Copied from [planogramDetail].
class PlanogramDetailProvider
    extends AutoDisposeStreamProvider<PlanogramsTableData?> {
  /// A single planogram by id, reactive to DB changes.
  ///
  /// Copied from [planogramDetail].
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
    Stream<PlanogramsTableData?> Function(PlanogramDetailRef provider) create,
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
  AutoDisposeStreamProviderElement<PlanogramsTableData?> createElement() {
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
mixin PlanogramDetailRef on AutoDisposeStreamProviderRef<PlanogramsTableData?> {
  /// The parameter `planogramId` of this provider.
  String get planogramId;
}

class _PlanogramDetailProviderElement
    extends AutoDisposeStreamProviderElement<PlanogramsTableData?>
    with PlanogramDetailRef {
  _PlanogramDetailProviderElement(super.provider);

  @override
  String get planogramId => (origin as PlanogramDetailProvider).planogramId;
}

String _$planogramEditorHash() => r'6aa8526fead7a1f7283dae093c7cd53c38a585f8';

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
