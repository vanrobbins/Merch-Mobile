// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planogram_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlanogramSlot _$PlanogramSlotFromJson(Map<String, dynamic> json) {
  return _PlanogramSlot.fromJson(json);
}

/// @nodoc
mixin _$PlanogramSlot {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  int get sequence => throw _privateConstructorUsedError;
  int get facings => throw _privateConstructorUsedError;

  /// Serializes this PlanogramSlot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanogramSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanogramSlotCopyWith<PlanogramSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanogramSlotCopyWith<$Res> {
  factory $PlanogramSlotCopyWith(
          PlanogramSlot value, $Res Function(PlanogramSlot) then) =
      _$PlanogramSlotCopyWithImpl<$Res, PlanogramSlot>;
  @useResult
  $Res call({String id, String productId, int sequence, int facings});
}

/// @nodoc
class _$PlanogramSlotCopyWithImpl<$Res, $Val extends PlanogramSlot>
    implements $PlanogramSlotCopyWith<$Res> {
  _$PlanogramSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanogramSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? sequence = null,
    Object? facings = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sequence: null == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
      facings: null == facings
          ? _value.facings
          : facings // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanogramSlotImplCopyWith<$Res>
    implements $PlanogramSlotCopyWith<$Res> {
  factory _$$PlanogramSlotImplCopyWith(
          _$PlanogramSlotImpl value, $Res Function(_$PlanogramSlotImpl) then) =
      __$$PlanogramSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String productId, int sequence, int facings});
}

/// @nodoc
class __$$PlanogramSlotImplCopyWithImpl<$Res>
    extends _$PlanogramSlotCopyWithImpl<$Res, _$PlanogramSlotImpl>
    implements _$$PlanogramSlotImplCopyWith<$Res> {
  __$$PlanogramSlotImplCopyWithImpl(
      _$PlanogramSlotImpl _value, $Res Function(_$PlanogramSlotImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlanogramSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? sequence = null,
    Object? facings = null,
  }) {
    return _then(_$PlanogramSlotImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sequence: null == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
      facings: null == facings
          ? _value.facings
          : facings // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanogramSlotImpl implements _PlanogramSlot {
  const _$PlanogramSlotImpl(
      {required this.id,
      required this.productId,
      required this.sequence,
      this.facings = 1});

  factory _$PlanogramSlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanogramSlotImplFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  @override
  final int sequence;
  @override
  @JsonKey()
  final int facings;

  @override
  String toString() {
    return 'PlanogramSlot(id: $id, productId: $productId, sequence: $sequence, facings: $facings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanogramSlotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.facings, facings) || other.facings == facings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, productId, sequence, facings);

  /// Create a copy of PlanogramSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanogramSlotImplCopyWith<_$PlanogramSlotImpl> get copyWith =>
      __$$PlanogramSlotImplCopyWithImpl<_$PlanogramSlotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanogramSlotImplToJson(
      this,
    );
  }
}

abstract class _PlanogramSlot implements PlanogramSlot {
  const factory _PlanogramSlot(
      {required final String id,
      required final String productId,
      required final int sequence,
      final int facings}) = _$PlanogramSlotImpl;

  factory _PlanogramSlot.fromJson(Map<String, dynamic> json) =
      _$PlanogramSlotImpl.fromJson;

  @override
  String get id;
  @override
  String get productId;
  @override
  int get sequence;
  @override
  int get facings;

  /// Create a copy of PlanogramSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanogramSlotImplCopyWith<_$PlanogramSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
