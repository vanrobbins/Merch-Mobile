// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Store _$StoreFromJson(Map<String, dynamic> json) {
  return _Store.fromJson(json);
}

/// @nodoc
mixin _$Store {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get inviteCode => throw _privateConstructorUsedError;
  String get ownerUid => throw _privateConstructorUsedError;
  double? get widthFt => throw _privateConstructorUsedError;
  double? get depthFt => throw _privateConstructorUsedError;
  String? get entranceJson => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Store to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreCopyWith<Store> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreCopyWith<$Res> {
  factory $StoreCopyWith(Store value, $Res Function(Store) then) =
      _$StoreCopyWithImpl<$Res, Store>;
  @useResult
  $Res call(
      {String id,
      String name,
      String inviteCode,
      String ownerUid,
      double? widthFt,
      double? depthFt,
      String? entranceJson,
      DateTime createdAt});
}

/// @nodoc
class _$StoreCopyWithImpl<$Res, $Val extends Store>
    implements $StoreCopyWith<$Res> {
  _$StoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? inviteCode = null,
    Object? ownerUid = null,
    Object? widthFt = freezed,
    Object? depthFt = freezed,
    Object? entranceJson = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      inviteCode: null == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
      ownerUid: null == ownerUid
          ? _value.ownerUid
          : ownerUid // ignore: cast_nullable_to_non_nullable
              as String,
      widthFt: freezed == widthFt
          ? _value.widthFt
          : widthFt // ignore: cast_nullable_to_non_nullable
              as double?,
      depthFt: freezed == depthFt
          ? _value.depthFt
          : depthFt // ignore: cast_nullable_to_non_nullable
              as double?,
      entranceJson: freezed == entranceJson
          ? _value.entranceJson
          : entranceJson // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoreImplCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$$StoreImplCopyWith(
          _$StoreImpl value, $Res Function(_$StoreImpl) then) =
      __$$StoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String inviteCode,
      String ownerUid,
      double? widthFt,
      double? depthFt,
      String? entranceJson,
      DateTime createdAt});
}

/// @nodoc
class __$$StoreImplCopyWithImpl<$Res>
    extends _$StoreCopyWithImpl<$Res, _$StoreImpl>
    implements _$$StoreImplCopyWith<$Res> {
  __$$StoreImplCopyWithImpl(
      _$StoreImpl _value, $Res Function(_$StoreImpl) _then)
      : super(_value, _then);

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? inviteCode = null,
    Object? ownerUid = null,
    Object? widthFt = freezed,
    Object? depthFt = freezed,
    Object? entranceJson = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$StoreImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      inviteCode: null == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
      ownerUid: null == ownerUid
          ? _value.ownerUid
          : ownerUid // ignore: cast_nullable_to_non_nullable
              as String,
      widthFt: freezed == widthFt
          ? _value.widthFt
          : widthFt // ignore: cast_nullable_to_non_nullable
              as double?,
      depthFt: freezed == depthFt
          ? _value.depthFt
          : depthFt // ignore: cast_nullable_to_non_nullable
              as double?,
      entranceJson: freezed == entranceJson
          ? _value.entranceJson
          : entranceJson // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoreImpl implements _Store {
  const _$StoreImpl(
      {required this.id,
      required this.name,
      required this.inviteCode,
      required this.ownerUid,
      this.widthFt,
      this.depthFt,
      this.entranceJson,
      required this.createdAt});

  factory _$StoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoreImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String inviteCode;
  @override
  final String ownerUid;
  @override
  final double? widthFt;
  @override
  final double? depthFt;
  @override
  final String? entranceJson;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Store(id: $id, name: $name, inviteCode: $inviteCode, ownerUid: $ownerUid, widthFt: $widthFt, depthFt: $depthFt, entranceJson: $entranceJson, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.ownerUid, ownerUid) ||
                other.ownerUid == ownerUid) &&
            (identical(other.widthFt, widthFt) || other.widthFt == widthFt) &&
            (identical(other.depthFt, depthFt) || other.depthFt == depthFt) &&
            (identical(other.entranceJson, entranceJson) ||
                other.entranceJson == entranceJson) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, inviteCode, ownerUid,
      widthFt, depthFt, entranceJson, createdAt);

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreImplCopyWith<_$StoreImpl> get copyWith =>
      __$$StoreImplCopyWithImpl<_$StoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoreImplToJson(
      this,
    );
  }
}

abstract class _Store implements Store {
  const factory _Store(
      {required final String id,
      required final String name,
      required final String inviteCode,
      required final String ownerUid,
      final double? widthFt,
      final double? depthFt,
      final String? entranceJson,
      required final DateTime createdAt}) = _$StoreImpl;

  factory _Store.fromJson(Map<String, dynamic> json) = _$StoreImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get inviteCode;
  @override
  String get ownerUid;
  @override
  double? get widthFt;
  @override
  double? get depthFt;
  @override
  String? get entranceJson;
  @override
  DateTime get createdAt;

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreImplCopyWith<_$StoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
