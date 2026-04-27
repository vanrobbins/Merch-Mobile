// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StoreMembership _$StoreMembershipFromJson(Map<String, dynamic> json) {
  return _StoreMembership.fromJson(json);
}

/// @nodoc
mixin _$StoreMembership {
  String get id => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get userUid => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // coordinator | manager | staff
  String get displayName => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending | active | rejected
  int get joinedAt => throw _privateConstructorUsedError;

  /// Serializes this StoreMembership to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoreMembership
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreMembershipCopyWith<StoreMembership> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreMembershipCopyWith<$Res> {
  factory $StoreMembershipCopyWith(
          StoreMembership value, $Res Function(StoreMembership) then) =
      _$StoreMembershipCopyWithImpl<$Res, StoreMembership>;
  @useResult
  $Res call(
      {String id,
      String storeId,
      String userUid,
      String role,
      String displayName,
      String status,
      int joinedAt});
}

/// @nodoc
class _$StoreMembershipCopyWithImpl<$Res, $Val extends StoreMembership>
    implements $StoreMembershipCopyWith<$Res> {
  _$StoreMembershipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoreMembership
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? userUid = null,
    Object? role = null,
    Object? displayName = null,
    Object? status = null,
    Object? joinedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      userUid: null == userUid
          ? _value.userUid
          : userUid // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoreMembershipImplCopyWith<$Res>
    implements $StoreMembershipCopyWith<$Res> {
  factory _$$StoreMembershipImplCopyWith(_$StoreMembershipImpl value,
          $Res Function(_$StoreMembershipImpl) then) =
      __$$StoreMembershipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String storeId,
      String userUid,
      String role,
      String displayName,
      String status,
      int joinedAt});
}

/// @nodoc
class __$$StoreMembershipImplCopyWithImpl<$Res>
    extends _$StoreMembershipCopyWithImpl<$Res, _$StoreMembershipImpl>
    implements _$$StoreMembershipImplCopyWith<$Res> {
  __$$StoreMembershipImplCopyWithImpl(
      _$StoreMembershipImpl _value, $Res Function(_$StoreMembershipImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoreMembership
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? userUid = null,
    Object? role = null,
    Object? displayName = null,
    Object? status = null,
    Object? joinedAt = null,
  }) {
    return _then(_$StoreMembershipImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      userUid: null == userUid
          ? _value.userUid
          : userUid // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoreMembershipImpl implements _StoreMembership {
  const _$StoreMembershipImpl(
      {required this.id,
      required this.storeId,
      required this.userUid,
      required this.role,
      required this.displayName,
      required this.status,
      required this.joinedAt});

  factory _$StoreMembershipImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoreMembershipImplFromJson(json);

  @override
  final String id;
  @override
  final String storeId;
  @override
  final String userUid;
  @override
  final String role;
// coordinator | manager | staff
  @override
  final String displayName;
  @override
  final String status;
// pending | active | rejected
  @override
  final int joinedAt;

  @override
  String toString() {
    return 'StoreMembership(id: $id, storeId: $storeId, userUid: $userUid, role: $role, displayName: $displayName, status: $status, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreMembershipImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.userUid, userUid) || other.userUid == userUid) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, storeId, userUid, role, displayName, status, joinedAt);

  /// Create a copy of StoreMembership
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreMembershipImplCopyWith<_$StoreMembershipImpl> get copyWith =>
      __$$StoreMembershipImplCopyWithImpl<_$StoreMembershipImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoreMembershipImplToJson(
      this,
    );
  }
}

abstract class _StoreMembership implements StoreMembership {
  const factory _StoreMembership(
      {required final String id,
      required final String storeId,
      required final String userUid,
      required final String role,
      required final String displayName,
      required final String status,
      required final int joinedAt}) = _$StoreMembershipImpl;

  factory _StoreMembership.fromJson(Map<String, dynamic> json) =
      _$StoreMembershipImpl.fromJson;

  @override
  String get id;
  @override
  String get storeId;
  @override
  String get userUid;
  @override
  String get role; // coordinator | manager | staff
  @override
  String get displayName;
  @override
  String get status; // pending | active | rejected
  @override
  int get joinedAt;

  /// Create a copy of StoreMembership
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreMembershipImplCopyWith<_$StoreMembershipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
