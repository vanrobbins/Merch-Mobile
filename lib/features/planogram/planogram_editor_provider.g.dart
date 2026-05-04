// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planogram_editor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$planogramEditorNotifierHash() =>
    r'8371be800d313922fb067a26bf498e46b67e0a92';

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

abstract class _$PlanogramEditorNotifier
    extends BuildlessAutoDisposeNotifier<PlanogramEditorState> {
  late final String planogramId;

  PlanogramEditorState build(
    String planogramId,
  );
}

/// See also [PlanogramEditorNotifier].
@ProviderFor(PlanogramEditorNotifier)
const planogramEditorNotifierProvider = PlanogramEditorNotifierFamily();

/// See also [PlanogramEditorNotifier].
class PlanogramEditorNotifierFamily extends Family<PlanogramEditorState> {
  /// See also [PlanogramEditorNotifier].
  const PlanogramEditorNotifierFamily();

  /// See also [PlanogramEditorNotifier].
  PlanogramEditorNotifierProvider call(
    String planogramId,
  ) {
    return PlanogramEditorNotifierProvider(
      planogramId,
    );
  }

  @override
  PlanogramEditorNotifierProvider getProviderOverride(
    covariant PlanogramEditorNotifierProvider provider,
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
  String? get name => r'planogramEditorNotifierProvider';
}

/// See also [PlanogramEditorNotifier].
class PlanogramEditorNotifierProvider extends AutoDisposeNotifierProviderImpl<
    PlanogramEditorNotifier, PlanogramEditorState> {
  /// See also [PlanogramEditorNotifier].
  PlanogramEditorNotifierProvider(
    String planogramId,
  ) : this._internal(
          () => PlanogramEditorNotifier()..planogramId = planogramId,
          from: planogramEditorNotifierProvider,
          name: r'planogramEditorNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$planogramEditorNotifierHash,
          dependencies: PlanogramEditorNotifierFamily._dependencies,
          allTransitiveDependencies:
              PlanogramEditorNotifierFamily._allTransitiveDependencies,
          planogramId: planogramId,
        );

  PlanogramEditorNotifierProvider._internal(
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
  PlanogramEditorState runNotifierBuild(
    covariant PlanogramEditorNotifier notifier,
  ) {
    return notifier.build(
      planogramId,
    );
  }

  @override
  Override overrideWith(PlanogramEditorNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PlanogramEditorNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<PlanogramEditorNotifier,
      PlanogramEditorState> createElement() {
    return _PlanogramEditorNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanogramEditorNotifierProvider &&
        other.planogramId == planogramId;
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
mixin PlanogramEditorNotifierRef
    on AutoDisposeNotifierProviderRef<PlanogramEditorState> {
  /// The parameter `planogramId` of this provider.
  String get planogramId;
}

class _PlanogramEditorNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<PlanogramEditorNotifier,
        PlanogramEditorState> with PlanogramEditorNotifierRef {
  _PlanogramEditorNotifierProviderElement(super.provider);

  @override
  String get planogramId =>
      (origin as PlanogramEditorNotifierProvider).planogramId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
