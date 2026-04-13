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
  String get fixtureId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get season => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<PlanogramSlot> get slots => throw _privateConstructorUsedError;
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
      String fixtureId,
      String title,
      String season,
      String status,
      List<PlanogramSlot> slots,
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
    Object? fixtureId = null,
    Object? title = null,
    Object? season = null,
    Object? status = null,
    Object? slots = null,
    Object? publishedAt = freezed,
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
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      season: null == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      slots: null == slots
          ? _value.slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<PlanogramSlot>,
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
      String fixtureId,
      String title,
      String season,
      String status,
      List<PlanogramSlot> slots,
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
    Object? fixtureId = null,
    Object? title = null,
    Object? season = null,
    Object? status = null,
    Object? slots = null,
    Object? publishedAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_$PlanogramImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fixtureId: null == fixtureId
          ? _value.fixtureId
          : fixtureId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      season: null == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      slots: null == slots
          ? _value._slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<PlanogramSlot>,
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
      required this.fixtureId,
      required this.title,
      required this.season,
      this.status = 'draft',
      final List<PlanogramSlot> slots = const <PlanogramSlot>[],
      this.publishedAt,
      required this.updatedAt})
      : _slots = slots;

  factory _$PlanogramImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanogramImplFromJson(json);

  @override
  final String id;
  @override
  final String fixtureId;
  @override
  final String title;
  @override
  final String season;
  @override
  @JsonKey()
  final String status;
  final List<PlanogramSlot> _slots;
  @override
  @JsonKey()
  List<PlanogramSlot> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slots);
  }

  @override
  final DateTime? publishedAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Planogram(id: $id, fixtureId: $fixtureId, title: $title, season: $season, status: $status, slots: $slots, publishedAt: $publishedAt, updatedAt: $updatedAt)';
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
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._slots, _slots) &&
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
      status,
      const DeepCollectionEquality().hash(_slots),
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
      required final String fixtureId,
      required final String title,
      required final String season,
      final String status,
      final List<PlanogramSlot> slots,
      final DateTime? publishedAt,
      required final DateTime updatedAt}) = _$PlanogramImpl;

  factory _Planogram.fromJson(Map<String, dynamic> json) =
      _$PlanogramImpl.fromJson;

  @override
  String get id;
  @override
  String get fixtureId;
  @override
  String get title;
  @override
  String get season;
  @override
  String get status;
  @override
  List<PlanogramSlot> get slots;
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
