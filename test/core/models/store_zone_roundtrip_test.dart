import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/models/store_zone.dart';

void main() {
  test('StoreZone fromJson/toJson roundtrip', () {
    final zone = StoreZone(
      id: 'z1', name: 'WOMENS', colorValue: 0xFF3B6BC2,
      zoneType: 'womens', storeId: 'default',
      posX: 0.05, posY: 0.05, width: 0.4, height: 0.4,
      updatedAt: DateTime(2025),
    );
    expect(StoreZone.fromJson(zone.toJson()), equals(zone));
  });
}
