import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/planogram/slot_item.dart';

void main() {
  group('SlotItem JSON round-trip', () {
    test('all fields survive toJson/fromJson', () {
      const item = SlotItem(
        productId: 'p1',
        productName: 'Classic Tee',
        productSku: 'TS-001',
        category: 'tee',
        colorHex: '#A8472B',
      );
      final json = item.toJson();
      final restored = SlotItem.fromJson(json);
      expect(restored.productId, 'p1');
      expect(restored.productName, 'Classic Tee');
      expect(restored.category, 'tee');
      expect(restored.colorHex, '#A8472B');
    });

    test('missing category defaults to "other"', () {
      final json = <String, dynamic>{
        'productId': 'p2',
        'productName': 'Mystery',
        'productSku': 'X-001',
      };
      final item = SlotItem.fromJson(json);
      expect(item.category, 'other');
    });

    test('null colorHex omitted from toJson', () {
      const item = SlotItem(
          productId: 'p3', productName: 'N', productSku: 'N-1', category: 'shirt');
      expect(item.toJson().containsKey('colorHex'), isFalse);
    });
  });
}
