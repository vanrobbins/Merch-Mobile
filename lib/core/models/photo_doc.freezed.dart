// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PhotoDoc _$PhotoDocFromJson(Map<String, dynamic> json) {
  return _PhotoDoc.fromJson(json);
}

/// @nodoc
mixin _$PhotoDoc {
  String get id => throw _privateConstructorUsedError;
  String get fixtureId => throw _privateConstructorUsedError;
  String get phase => throw _privateConstructorUsedError; // before/after
  String get localPath => throw _privateConstructorUsedError;
  String get remoteUrl => throw _privateConstructorUsedError;
  String get uploadStatus => throw _privateConstructorUsedError;
  String get approvalStatus => throw _privateConstructorUsedError;
  String? get planogramId => throw _privateConstructorUsedError;
  DateTime get capturedAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PhotoDoc to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhotoDoc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoDocCopyWith<PhotoDoc> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoDocCopyWith<$Res> {
  factory $PhotoDocCopyWith(PhotoDoc value, $Res Function(PhotoDoc) then) =
      _$PhotoDocCopyWithImpl<$Res, PhotoDoc>;
  @useResult
  $Res call(
      {String id,
      String fixtureId,
      String phase,
      String localPath,
      String remoteUrl,
      String uploadStatus,
      String approvalStatus,
      String? planogramId,
      DateTime capturedAt,
      DateTime updatedAt});
}

/// @nodoc
class _$PhotoDocCopyWithImpl<$Res, $Val extends PhotoDoc>
    implements $PhotoDocCopyWith<$Res> {
  _$PhotoDocCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoDoc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fixtureId = null,
    Object? phase = null,
    Object? localPath = null,
    Object? remoteUrl = null,
    Object? uploadStatus = null,
    Object? approvalStatus = null,
    Object? planogramId = freezed,
    Object? capturedAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fixtureId: null == fixtureId
          ? _value.fixtureId
          : fixtureId // ignore: cast_nullable_to_non_nullable
              as String,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as String,
      localPath: null == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String,
      remoteUrl: null == remoteUrl
          ? _value.remoteUrl
          : remoteUrl // ignore: cast_nullable_to_non_nullable
              as String,
      uploadStatus: null == uploadStatus
          ? _value.uploadStatus
          : uploadStatus // ignore: cast_nullable_to_non_nullable
              as String,
      approvalStatus: null == approvalStatus
          ? _value.approvalStatus
          : approvalStatus // ignore: cast_nullable_to_non_nullable
              as String,
      planogramId: freezed == planogramId
          ? _value.planogramId
          : planogramId // ignore: cast_nullable_to_non_nullable
              as String?,
      capturedAt: null == capturedAt
          ? _value.capturedAt
          : capturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhotoDocImplCopyWith<$Res>
    implements $PhotoDocCopyWith<$Res> {
  factory _$$PhotoDocImplCopyWith(
          _$PhotoDocImpl value, $Res Function(_$PhotoDocImpl) then) =
      __$$PhotoDocImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fixtureId,
      String phase,
      String localPath,
      String remoteUrl,
      String uploadStatus,
      String approvalStatus,
      String? planogramId,
      DateTime capturedAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$PhotoDocImplCopyWithImpl<$Res>
    extends _$PhotoDocCopyWithImpl<$Res, _$PhotoDocImpl>
    implements _$$PhotoDocImplCopyWith<$Res> {
  __$$PhotoDocImplCopyWithImpl(
      _$PhotoDocImpl _value, $Res Function(_$PhotoDocImpl) _then)
      : super(_value, _then);

  /// Create a copy of PhotoDoc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fixtureId = null,
    Object? phase = null,
    Object? localPath = null,
    Object? remoteUrl = null,
    Object? uploadStatus = null,
    Object? approvalStatus = null,
    Object? planogramId = freezed,
    Object? capturedAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$PhotoDocImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fixtureId: null == fixtureId
          ? _value.fixtureId
          : fixtureId // ignore: cast_nullable_to_non_nullable
              as String,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as String,
      localPath: null == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String,
      remoteUrl: null == remoteUrl
          ? _value.remoteUrl
          : remoteUrl // ignore: cast_nullable_to_non_nullable
              as String,
      uploadStatus: null == uploadStatus
          ? _value.uploadStatus
          : uploadStatus // ignore: cast_nullable_to_non_nullable
              as String,
      approvalStatus: null == approvalStatus
          ? _value.approvalStatus
          : approvalStatus // ignore: cast_nullable_to_non_nullable
              as String,
      planogramId: freezed == planogramId
          ? _value.planogramId
          : planogramId // ignore: cast_nullable_to_non_nullable
              as String?,
      capturedAt: null == capturedAt
          ? _value.capturedAt
          : capturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoDocImpl implements _PhotoDoc {
  const _$PhotoDocImpl(
      {required this.id,
      required this.fixtureId,
      required this.phase,
      required this.localPath,
      this.remoteUrl = '',
      this.uploadStatus = 'pending',
      this.approvalStatus = 'pending',
      this.planogramId,
      required this.capturedAt,
      required this.updatedAt});

  factory _$PhotoDocImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoDocImplFromJson(json);

  @override
  final String id;
  @override
  final String fixtureId;
  @override
  final String phase;
// before/after
  @override
  final String localPath;
  @override
  @JsonKey()
  final String remoteUrl;
  @override
  @JsonKey()
  final String uploadStatus;
  @override
  @JsonKey()
  final String approvalStatus;
  @override
  final String? planogramId;
  @override
  final DateTime capturedAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'PhotoDoc(id: $id, fixtureId: $fixtureId, phase: $phase, localPath: $localPath, remoteUrl: $remoteUrl, uploadStatus: $uploadStatus, approvalStatus: $approvalStatus, planogramId: $planogramId, capturedAt: $capturedAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoDocImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fixtureId, fixtureId) ||
                other.fixtureId == fixtureId) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.remoteUrl, remoteUrl) ||
                other.remoteUrl == remoteUrl) &&
            (identical(other.uploadStatus, uploadStatus) ||
                other.uploadStatus == uploadStatus) &&
            (identical(other.approvalStatus, approvalStatus) ||
                other.approvalStatus == approvalStatus) &&
            (identical(other.planogramId, planogramId) ||
                other.planogramId == planogramId) &&
            (identical(other.capturedAt, capturedAt) ||
                other.capturedAt == capturedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fixtureId,
      phase,
      localPath,
      remoteUrl,
      uploadStatus,
      approvalStatus,
      planogramId,
      capturedAt,
      updatedAt);

  /// Create a copy of PhotoDoc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoDocImplCopyWith<_$PhotoDocImpl> get copyWith =>
      __$$PhotoDocImplCopyWithImpl<_$PhotoDocImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoDocImplToJson(
      this,
    );
  }
}

abstract class _PhotoDoc implements PhotoDoc {
  const factory _PhotoDoc(
      {required final String id,
      required final String fixtureId,
      required final String phase,
      required final String localPath,
      final String remoteUrl,
      final String uploadStatus,
      final String approvalStatus,
      final String? planogramId,
      required final DateTime capturedAt,
      required final DateTime updatedAt}) = _$PhotoDocImpl;

  factory _PhotoDoc.fromJson(Map<String, dynamic> json) =
      _$PhotoDocImpl.fromJson;

  @override
  String get id;
  @override
  String get fixtureId;
  @override
  String get phase; // before/after
  @override
  String get localPath;
  @override
  String get remoteUrl;
  @override
  String get uploadStatus;
  @override
  String get approvalStatus;
  @override
  String? get planogramId;
  @override
  DateTime get capturedAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of PhotoDoc
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoDocImplCopyWith<_$PhotoDocImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
