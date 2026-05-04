// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planogram.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Planogram _$PlanogramFromJson(Map<String, dynamic> json) {
  return _Planogram.fromJson(json);
}

/// @nodoc
mixin _$Planogram {
  String get id => throw _privateConstructorUsedError;
  String? get fixtureId =>
      throw _privateConstructorUsedError; // nullable — standalone planograms allowed
  String get title => throw _privateConstructorUsedError;
  String get season => throw _privateConstructorUsedError;
  String get planogramType =>
      throw _privateConstructorUsedError; // 'wall' | 'shelf' | 'table' | 'rack'
  int get rows => throw _privateConstructorUsedError;
  int get cols => throw _privateConstructorUsedError;
  double? get linearFt => throw _privateConstructorUsedError; // wall/shelf only
  String get status => throw _privateConstructorUsedError;
  String get slotsJson => throw _privateConstructorUsedError;
  String get rowsJson => throw _privateConstructorUsedError;
  String get looksJson => throw _privateConstructorUsedError;
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Planogram to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Planogram
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanogramCopyWith<Planogram> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanogramCopyWith<$Res> {
  factory $PlanogramCopyWith(Planogram value, $Res Function(Planogram) then) =
      _$PlanogramCopyWithImpl<$Res, Planogram>;
  @useResult
  $Res call(
      {String id,
      String? fixtureId,
      String title,
      String season,
      String planogramType,
      int rows,
      int cols,
      double? linearFt,
      String status,
      String slotsJson,
      String rowsJson,
      String looksJson,
      DateTime? publishedAt,
      DateTime updatedAt});
}

/// @nodoc
class _$PlanogramCopyWithImpl<$Res, $Val extends Planogram>
    implements $PlanogramCopyWith<$Res> {
  _$PlanogramCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Planogram
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fixtureId = freezed,
    Object? title = null,
    Object? season = null,
    Object? planogramType = null,
    Object? rows = null,
    Object? cols = null,
    Object? linearFt = freezed,
    Object? status = null,
    Object? slotsJson = null,
    Object? rowsJson = null,
    Object? looksJson = null,
    Object? publishedAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fixtureId: freezed == fixtureId
          ? _value.fixtureId
          : fixtureId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      season: null == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as String,
      planogramType: null == planogramType
          ? _value.planogramType
          : planogramType // ignore: cast_nullable_to_non_nullable
              as String,
      rows: null == rows
          ? _value.rows
          : rows // ignore: cast_nullable_to_non_nullable
              as int,
      cols: null == cols
          ? _value.cols
          : cols // ignore: cast_nullable_to_non_nullable
              as int,
      linearFt: freezed == linearFt
          ? _value.linearFt
          : linearFt // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      slotsJson: null == slotsJson
          ? _value.slotsJson
          : slotsJson // ignore: cast_nullable_to_non_nullable
              as String,
      rowsJson: null == rowsJson
          ? _value.rowsJson
          : rowsJson // ignore: cast_nullable_to_non_nullable
              as String,
      looksJson: null == looksJson
          ? _value.looksJson
          : looksJson // ignore: cast_nullable_to_non_nullable
              as String,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanogramImplCopyWith<$Res>
    implements $PlanogramCopyWith<$Res> {
  factory _$$PlanogramImplCopyWith(
          _$PlanogramImpl value, $Res Function(_$PlanogramImpl) then) =
      __$$PlanogramImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? fixtureId,
      String title,
      String season,
      String planogramType,
      int rows,
      int cols,
      double? linearFt,
      String status,
      String slotsJson,
      String rowsJson,
      String looksJson,
      DateTime? publishedAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$PlanogramImplCopyWithImpl<$Res>
    extends _$PlanogramCopyWithImpl<$Res, _$PlanogramImpl>
    implements _$$PlanogramImplCopyWith<$Res> {
  __$$PlanogramImplCopyWithImpl(
      _$PlanogramImpl _value, $Res Function(_$PlanogramImpl) _then)
      : super(_value, _then);

  /// Create a copy of Planogram
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fixtureId = freezed,
    Object? title = null,
    Object? season = null,
    Object? planogramType = null,
    Object? rows = null,
    Object? cols = null,
    Object? linearFt = freezed,
    Object? status = null,
    Object? slotsJson = null,
    Object? rowsJson = null,
    Object? looksJson = null,
    Object? publishedAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_$PlanogramImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fixtureId: freezed == fixtureId
          ? _value.fixtureId
          : fixtureId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      season: null == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as String,
      planogramType: null == planogramType
          ? _value.planogramType
          : planogramType // ignore: cast_nullable_to_non_nullable
              as String,
      rows: null == rows
          ? _value.rows
          : rows // ignore: cast_nullable_to_non_nullable
              as int,
      cols: null == cols
          ? _value.cols
          : cols // ignore: cast_nullable_to_non_nullable
              as int,
      linearFt: freezed == linearFt
          ? _value.linearFt
          : linearFt // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      slotsJson: null == slotsJson
          ? _value.slotsJson
          : slotsJson // ignore: cast_nullable_to_non_nullable
              as String,
      rowsJson: null == rowsJson
          ? _value.rowsJson
          : rowsJson // ignore: cast_nullable_to_non_nullable
              as String,
      looksJson: null == looksJson
          ? _value.looksJson
          : looksJson // ignore: cast_nullable_to_non_nullable
              as String,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanogramImpl implements _Planogram {
  const _$PlanogramImpl(
      {required this.id,
      this.fixtureId,
      required this.title,
      required this.season,
      this.planogramType = 'shelf',
      this.rows = 2,
      this.cols = 4,
      this.linearFt,
      this.status = 'draft',
      this.slotsJson = '',
      this.rowsJson = '',
      this.looksJson = '',
      this.publishedAt,
      required this.updatedAt});

  factory _$PlanogramImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanogramImplFromJson(json);

  @override
  final String id;
  @override
  final String? fixtureId;
// nullable — standalone planograms allowed
  @override
  final String title;
  @override
  final String season;
  @override
  @JsonKey()
  final String planogramType;
// 'wall' | 'shelf' | 'table' | 'rack'
  @override
  @JsonKey()
  final int rows;
  @override
  @JsonKey()
  final int cols;
  @override
  final double? linearFt;
// wall/shelf only
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String slotsJson;
  @override
  @JsonKey()
  final String rowsJson;
  @override
  @JsonKey()
  final String looksJson;
  @override
  final DateTime? publishedAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Planogram(id: $id, fixtureId: $fixtureId, title: $title, season: $season, planogramType: $planogramType, rows: $rows, cols: $cols, linearFt: $linearFt, status: $status, slotsJson: $slotsJson, rowsJson: $rowsJson, looksJson: $looksJson, publishedAt: $publishedAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanogramImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fixtureId, fixtureId) ||
                other.fixtureId == fixtureId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.planogramType, planogramType) ||
                other.planogramType == planogramType) &&
            (identical(other.rows, rows) || other.rows == rows) &&
            (identical(other.cols, cols) || other.cols == cols) &&
            (identical(other.linearFt, linearFt) ||
                other.linearFt == linearFt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.slotsJson, slotsJson) ||
                other.slotsJson == slotsJson) &&
            (identical(other.rowsJson, rowsJson) ||
                other.rowsJson == rowsJson) &&
            (identical(other.looksJson, looksJson) ||
                other.looksJson == looksJson) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fixtureId,
      title,
      season,
      planogramType,
      rows,
      cols,
      linearFt,
      status,
      slotsJson,
      rowsJson,
      looksJson,
      publishedAt,
      updatedAt);

  /// Create a copy of Planogram
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanogramImplCopyWith<_$PlanogramImpl> get copyWith =>
      __$$PlanogramImplCopyWithImpl<_$PlanogramImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanogramImplToJson(
      this,
    );
  }
}

abstract class _Planogram implements Planogram {
  const factory _Planogram(
      {required final String id,
      final String? fixtureId,
      required final String title,
      required final String season,
      final String planogramType,
      final int rows,
      final int cols,
      final double? linearFt,
      final String status,
      final String slotsJson,
      final String rowsJson,
      final String looksJson,
      final DateTime? publishedAt,
      required final DateTime updatedAt}) = _$PlanogramImpl;

  factory _Planogram.fromJson(Map<String, dynamic> json) =
      _$PlanogramImpl.fromJson;

  @override
  String get id;
  @override
  String? get fixtureId; // nullable — standalone planograms allowed
  @override
  String get title;
  @override
  String get season;
  @override
  String get planogramType; // 'wall' | 'shelf' | 'table' | 'rack'
  @override
  int get rows;
  @override
  int get cols;
  @override
  double? get linearFt; // wall/shelf only
  @override
  String get status;
  @override
  String get slotsJson;
  @override
  String get rowsJson;
  @override
  String get looksJson;
  @override
  DateTime? get publishedAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Planogram
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanogramImplCopyWith<_$PlanogramImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
