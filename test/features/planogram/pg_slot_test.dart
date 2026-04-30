import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/planogram/planogram_slot.dart';
import 'package:merch_mobile/features/planogram/slot_item.dart';

void main() {
  group('PgSlot.fromJson / toJson round-trip', () {
    test('all new fields survive round-trip', () {
      const slot = PgSlot(
        id: 'slot_1_2',
        position: 7,
        row: 1,
        col: 2,
        productId: 'prod1',
        productName: 'Classic Tee',
        productSku: 'TS-001',
        presentationMode: 'shoulder_out',
        spanCols: 2,
        spanRows: 1,
        rotation: 90,
        colorHex: '#A8472B',
        sectionLabel: 'Tops',
      );
      final json = slot.toJson();
      final restored = PgSlot.fromJson(json);
      expect(restored.id, slot.id);
      expect(restored.row, 1);
      expect(restored.col, 2);
      expect(restored.presentationMode, 'shoulder_out');
      expect(restored.spanCols, 2);
      expect(restored.rotation, 90);
      expect(restored.colorHex, '#A8472B');
      expect(restored.sectionLabel, 'Tops');
    });

    test('back-compat: old data without row/col defaults row=0, col=position-1', () {
      final oldJson = <String, dynamic>{
        'id': 'slot_3',
        'position': 3,
        'productId': null,
      };
      final slot = PgSlot.fromJson(oldJson);
      expect(slot.row, 0);
      expect(slot.col, 2); // position - 1
      expect(slot.presentationMode, 'face_out');
      expect(slot.spanCols, 1);
    });

    test('back-compat: legacy "sequence" field maps to position', () {
      final oldJson = <String, dynamic>{
        'id': 'slot_5',
        'sequence': 5,
      };
      final slot = PgSlot.fromJson(oldJson);
      expect(slot.position, 5);
    });
  });

  group('PgSlot.encodeList / decodeList', () {
    test('empty string returns empty list', () {
      expect(PgSlot.decodeList(''), isEmpty);
    });

    test('round-trips a grid of 6 slots', () {
      // defaultGrid(2 rows, 3 cols, 'shelf') → 6 slots
      final slots = PgSlot.defaultGrid(2, 3, 'shelf');
      expect(slots.length, 6);
      final json = PgSlot.encodeList(slots);
      final restored = PgSlot.decodeList(json);
      expect(restored.length, 6);
      // slot index 4 is row=1, col=1 (second row, second column)
      expect(restored[4].row, 1);
      expect(restored[4].col, 1);
    });
  });

  group('PgSlot.cleared', () {
    test('clears product fields and resets spans/rotation', () {
      const slot = PgSlot(
        id: 's1',
        position: 1,
        row: 0,
        col: 0,
        productId: 'p1',
        productName: 'Jacket',
        productSku: 'JK-01',
        spanCols: 3,
        rotation: 180,
      );
      final cleared = slot.cleared();
      expect(cleared.productId, isNull);
      expect(cleared.productName, isNull);
      expect(cleared.spanCols, 1);
      expect(cleared.rotation, 0);
      // row/col preserved
      expect(cleared.row, 0);
      expect(cleared.col, 0);
    });
  });

  group('PgSlot.defaultMode', () {
    test('wall → face_out', () => expect(PgSlot.defaultMode('wall'), 'face_out'));
    test('rack → shoulder_out', () => expect(PgSlot.defaultMode('rack'), 'shoulder_out'));
    test('shelf → shoulder_out', () => expect(PgSlot.defaultMode('shelf'), 'shoulder_out'));
    test('table → folded', () => expect(PgSlot.defaultMode('table'), 'folded'));
  });

  group('PgSlot new fields', () {
    test('new fields survive round-trip', () {
      final slot = PgSlot(
        id: 'slot_1_0',
        position: 1,
        col: 1,
        nodeType: 'faceout',
        items: [
          SlotItem(
              productId: 'p1',
              productName: 'Shirt A',
              productSku: 'SA-001',
              category: 'shirt',
              colorHex: '#BF5534'),
        ],
        subRow: 4,
        spanQuarters: 5,
      );
      final restored = PgSlot.fromJson(slot.toJson());
      expect(restored.nodeType, 'faceout');
      expect(restored.items.length, 1);
      expect(restored.items.first.productSku, 'SA-001');
      expect(restored.items.first.category, 'shirt');
      expect(restored.subRow, 4);
      expect(restored.spanQuarters, 5);
    });

    test('back-compat: legacy productId wrapped into items', () {
      final oldJson = <String, dynamic>{
        'id': 'slot_0_2',
        'position': 3,
        'row': 0,
        'col': 2,
        'productId': 'p99',
        'productName': 'Old Jacket',
        'productSku': 'OJ-001',
        'spanRows': 2,
      };
      final slot = PgSlot.fromJson(oldJson);
      expect(slot.items.length, 1);
      expect(slot.items.first.productId, 'p99');
      expect(slot.items.first.productName, 'Old Jacket');
      expect(slot.items.first.category, 'other'); // no category in old data
      expect(slot.subRow, 0); // row 0 → subRow 0
      expect(slot.spanQuarters, 8); // spanRows 2 → 8 quarters
      expect(slot.nodeType, 'shoulder'); // default
    });

    test('back-compat: no items and no productId → empty items list', () {
      final json = <String, dynamic>{'id': 's1', 'position': 1, 'row': 0, 'col': 0};
      final slot = PgSlot.fromJson(json);
      expect(slot.items, isEmpty);
      expect(slot.nodeType, 'shoulder');
    });

    test('cleared() removes items and resets spanQuarters to 4', () {
      final slot = PgSlot(
        id: 's1',
        position: 1,
        col: 0,
        nodeType: 'faceout',
        items: [SlotItem(productId: 'p1', productName: 'X', productSku: 'X', category: 'shirt')],
        subRow: 0,
        spanQuarters: 5,
      );
      final cleared = slot.cleared();
      expect(cleared.items, isEmpty);
      expect(cleared.spanQuarters, 4);
      expect(cleared.nodeType, 'faceout'); // type preserved
    });

    test('items key present (even empty) takes priority over legacy productId', () {
      final json = <String, dynamic>{
        'id': 's2',
        'position': 1,
        'row': 0,
        'col': 0,
        'items': [],           // explicit empty list
        'productId': 'p99',   // stale legacy field co-existing
      };
      final slot = PgSlot.fromJson(json);
      // items key wins — do not fall through to productId synthesiser
      expect(slot.items, isEmpty);
      // legacy productId is preserved (needed by _GridView which reads it directly)
      expect(slot.productId, 'p99');
    });
  });
}
