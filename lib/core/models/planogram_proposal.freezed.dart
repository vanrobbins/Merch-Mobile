// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planogram_proposal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlanogramProposal _$PlanogramProposalFromJson(Map<String, dynamic> json) {
  return _PlanogramProposal.fromJson(json);
}

/// @nodoc
mixin _$PlanogramProposal {
  String get id => throw _privateConstructorUsedError;
  String get planogramId => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get proposedByUid => throw _privateConstructorUsedError;
  int get proposedAt => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending | approved | rejected
  String? get notes => throw _privateConstructorUsedError;
  String? get slotChanges => throw _privateConstructorUsedError; // JSON
  String? get reviewedByUid => throw _privateConstructorUsedError;
  int? get reviewedAt => throw _privateConstructorUsedError;

  /// Serializes this PlanogramProposal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanogramProposal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanogramProposalCopyWith<PlanogramProposal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanogramProposalCopyWith<$Res> {
  factory $PlanogramProposalCopyWith(
          PlanogramProposal value, $Res Function(PlanogramProposal) then) =
      _$PlanogramProposalCopyWithImpl<$Res, PlanogramProposal>;
  @useResult
  $Res call(
      {String id,
      String planogramId,
      String storeId,
      String proposedByUid,
      int proposedAt,
      String status,
      String? notes,
      String? slotChanges,
      String? reviewedByUid,
      int? reviewedAt});
}

/// @nodoc
class _$PlanogramProposalCopyWithImpl<$Res, $Val extends PlanogramProposal>
    implements $PlanogramProposalCopyWith<$Res> {
  _$PlanogramProposalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanogramProposal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planogramId = null,
    Object? storeId = null,
    Object? proposedByUid = null,
    Object? proposedAt = null,
    Object? status = null,
    Object? notes = freezed,
    Object? slotChanges = freezed,
    Object? reviewedByUid = freezed,
    Object? reviewedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planogramId: null == planogramId
          ? _value.planogramId
          : planogramId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      proposedByUid: null == proposedByUid
          ? _value.proposedByUid
          : proposedByUid // ignore: cast_nullable_to_non_nullable
              as String,
      proposedAt: null == proposedAt
          ? _value.proposedAt
          : proposedAt // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      slotChanges: freezed == slotChanges
          ? _value.slotChanges
          : slotChanges // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedByUid: freezed == reviewedByUid
          ? _value.reviewedByUid
          : reviewedByUid // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanogramProposalImplCopyWith<$Res>
    implements $PlanogramProposalCopyWith<$Res> {
  factory _$$PlanogramProposalImplCopyWith(_$PlanogramProposalImpl value,
          $Res Function(_$PlanogramProposalImpl) then) =
      __$$PlanogramProposalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String planogramId,
      String storeId,
      String proposedByUid,
      int proposedAt,
      String status,
      String? notes,
      String? slotChanges,
      String? reviewedByUid,
      int? reviewedAt});
}

/// @nodoc
class __$$PlanogramProposalImplCopyWithImpl<$Res>
    extends _$PlanogramProposalCopyWithImpl<$Res, _$PlanogramProposalImpl>
    implements _$$PlanogramProposalImplCopyWith<$Res> {
  __$$PlanogramProposalImplCopyWithImpl(_$PlanogramProposalImpl _value,
      $Res Function(_$PlanogramProposalImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlanogramProposal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planogramId = null,
    Object? storeId = null,
    Object? proposedByUid = null,
    Object? proposedAt = null,
    Object? status = null,
    Object? notes = freezed,
    Object? slotChanges = freezed,
    Object? reviewedByUid = freezed,
    Object? reviewedAt = freezed,
  }) {
    return _then(_$PlanogramProposalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planogramId: null == planogramId
          ? _value.planogramId
          : planogramId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      proposedByUid: null == proposedByUid
          ? _value.proposedByUid
          : proposedByUid // ignore: cast_nullable_to_non_nullable
              as String,
      proposedAt: null == proposedAt
          ? _value.proposedAt
          : proposedAt // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      slotChanges: freezed == slotChanges
          ? _value.slotChanges
          : slotChanges // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedByUid: freezed == reviewedByUid
          ? _value.reviewedByUid
          : reviewedByUid // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanogramProposalImpl implements _PlanogramProposal {
  const _$PlanogramProposalImpl(
      {required this.id,
      required this.planogramId,
      required this.storeId,
      required this.proposedByUid,
      required this.proposedAt,
      required this.status,
      this.notes,
      this.slotChanges,
      this.reviewedByUid,
      this.reviewedAt});

  factory _$PlanogramProposalImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanogramProposalImplFromJson(json);

  @override
  final String id;
  @override
  final String planogramId;
  @override
  final String storeId;
  @override
  final String proposedByUid;
  @override
  final int proposedAt;
  @override
  final String status;
// pending | approved | rejected
  @override
  final String? notes;
  @override
  final String? slotChanges;
// JSON
  @override
  final String? reviewedByUid;
  @override
  final int? reviewedAt;

  @override
  String toString() {
    return 'PlanogramProposal(id: $id, planogramId: $planogramId, storeId: $storeId, proposedByUid: $proposedByUid, proposedAt: $proposedAt, status: $status, notes: $notes, slotChanges: $slotChanges, reviewedByUid: $reviewedByUid, reviewedAt: $reviewedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanogramProposalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planogramId, planogramId) ||
                other.planogramId == planogramId) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.proposedByUid, proposedByUid) ||
                other.proposedByUid == proposedByUid) &&
            (identical(other.proposedAt, proposedAt) ||
                other.proposedAt == proposedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.slotChanges, slotChanges) ||
                other.slotChanges == slotChanges) &&
            (identical(other.reviewedByUid, reviewedByUid) ||
                other.reviewedByUid == reviewedByUid) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      planogramId,
      storeId,
      proposedByUid,
      proposedAt,
      status,
      notes,
      slotChanges,
      reviewedByUid,
      reviewedAt);

  /// Create a copy of PlanogramProposal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanogramProposalImplCopyWith<_$PlanogramProposalImpl> get copyWith =>
      __$$PlanogramProposalImplCopyWithImpl<_$PlanogramProposalImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanogramProposalImplToJson(
      this,
    );
  }
}

abstract class _PlanogramProposal implements PlanogramProposal {
  const factory _PlanogramProposal(
      {required final String id,
      required final String planogramId,
      required final String storeId,
      required final String proposedByUid,
      required final int proposedAt,
      required final String status,
      final String? notes,
      final String? slotChanges,
      final String? reviewedByUid,
      final int? reviewedAt}) = _$PlanogramProposalImpl;

  factory _PlanogramProposal.fromJson(Map<String, dynamic> json) =
      _$PlanogramProposalImpl.fromJson;

  @override
  String get id;
  @override
  String get planogramId;
  @override
  String get storeId;
  @override
  String get proposedByUid;
  @override
  int get proposedAt;
  @override
  String get status; // pending | approved | rejected
  @override
  String? get notes;
  @override
  String? get slotChanges; // JSON
  @override
  String? get reviewedByUid;
  @override
  int? get reviewedAt;

  /// Create a copy of PlanogramProposal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanogramProposalImplCopyWith<_$PlanogramProposalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
