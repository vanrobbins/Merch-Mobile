import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/planogram/planogram_slot.dart';

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
}
