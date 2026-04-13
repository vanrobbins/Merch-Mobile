import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_zone.freezed.dart';
part 'store_zone.g.dart';

@freezed
class StoreZone with _$StoreZone {
  const factory StoreZone({
    required String id,
    required String name,
    required int colorValue,
    required String zoneType,
    required String storeId,
    @Default(0.0) double posX,
    @Default(0.0) double posY,
    @Default(0.2) double width,
    @Default(0.2) double height,
    required DateTime updatedAt,
  }) = _StoreZone;

  factory StoreZone.fromJson(Map<String, dynamic> json) => _$StoreZoneFromJson(json);
}
