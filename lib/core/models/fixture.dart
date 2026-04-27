import 'package:freezed_annotation/freezed_annotation.dart';

part 'fixture.freezed.dart';
part 'fixture.g.dart';

@freezed
class Fixture with _$Fixture {
  const factory Fixture({
    required String id,
    String? zoneId,
    required String fixtureType,
    @Default(0.0) double posX,
    @Default(0.0) double posY,
    @Default(0.0) double rotation,
    @Default(4.0) double widthFt,
    @Default(2.0) double depthFt,
    @Default('') String label,
    String? planogramId,
    String? planogramIdBack,
    @Default(false) bool wallAdjacent,
    required DateTime updatedAt,
  }) = _Fixture;

  factory Fixture.fromJson(Map<String, dynamic> json) => _$FixtureFromJson(json);
}
