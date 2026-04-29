// Tests for v0.3 model copyWith logic and toFirestore() field mapping.
// Timestamp fields are skipped — we verify the non-Timestamp keys.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/models/mannequin.dart';
import 'package:merch_mobile/core/models/brand_color.dart';
import 'package:merch_mobile/core/models/mannequin_outfit_slot.dart';
import 'package:merch_mobile/core/models/platform_element.dart';
import 'package:merch_mobile/core/models/scene_prop.dart';

void main() {
  // ────────────────────────────────────────────────────────────
  // Mannequin
  // ────────────────────────────────────────────────────────────
  group('Mannequin.toFirestore', () {
    test('includes required fields', () {
      final m = Mannequin(
        id: 'id1',
        storeId: 's1',
        zoneId: 'z1',
        mannequinType: 'full_body',
        mountType: 'floor',
        positionX: 2.0,
        positionY: 3.5,
        rotation: 90.0,
        updatedAt: DateTime(2026, 4, 28),
      );
      final map = m.toFirestore();
      expect(map['storeId'], 's1');
      expect(map['zoneId'], 'z1');
      expect(map['mannequinType'], 'full_body');
      expect(map['mountType'], 'floor');
      expect(map['positionX'], 2.0);
      expect(map['positionY'], 3.5);
      expect(map['rotation'], 90.0);
    });

    test('updatedAt is serialised as a Timestamp', () {
      final dt = DateTime(2026, 4, 28);
      final m = Mannequin(
        id: 'id1',
        storeId: 's1',
        zoneId: 'z1',
        mannequinType: 'torso',
        mountType: 'floor',
        positionX: 0,
        positionY: 0,
        updatedAt: dt,
      );
      final map = m.toFirestore();
      expect(map['updatedAt'], isA<Timestamp>());
      expect((map['updatedAt'] as Timestamp).toDate(), dt);
    });

    test('omits null optional fields', () {
      final m = Mannequin(
        id: 'id1',
        storeId: 's1',
        zoneId: 'z1',
        mannequinType: 'torso',
        mountType: 'floor',
        positionX: 0,
        positionY: 0,
        updatedAt: DateTime(2026),
      );
      final map = m.toFirestore();
      expect(map.containsKey('name'), isFalse);
      expect(map.containsKey('outfitName'), isFalse);
      expect(map.containsKey('platformId'), isFalse);
      expect(map.containsKey('outfitNotes'), isFalse);
    });

    test('includes optional fields when set', () {
      final m = Mannequin(
        id: 'id1',
        storeId: 's1',
        zoneId: 'z1',
        mannequinType: 'full_body',
        mountType: 'floor',
        positionX: 0,
        positionY: 0,
        outfitName: 'Summer Look',
        name: 'Window M1',
        platformId: 'pl1',
        outfitNotes: 'Belt optional',
        updatedAt: DateTime(2026),
      );
      final map = m.toFirestore();
      expect(map['outfitName'], 'Summer Look');
      expect(map['name'], 'Window M1');
      expect(map['platformId'], 'pl1');
      expect(map['outfitNotes'], 'Belt optional');
    });
  });

  group('Mannequin.copyWith', () {
    final base = Mannequin(
      id: 'id1',
      storeId: 's1',
      zoneId: 'z1',
      mannequinType: 'torso',
      mountType: 'floor',
      positionX: 1.0,
      positionY: 2.0,
      updatedAt: DateTime(2026),
    );

    test('preserves id, storeId, zoneId', () {
      final updated = base.copyWith(outfitName: 'Look 1');
      expect(updated.id, 'id1');
      expect(updated.storeId, 's1');
      expect(updated.zoneId, 'z1');
    });

    test('updates outfitName', () {
      final updated = base.copyWith(outfitName: 'Look 1');
      expect(updated.outfitName, 'Look 1');
      expect(updated.mannequinType, 'torso');
    });

    test('updates rotation', () {
      final updated = base.copyWith(rotation: 45.0);
      expect(updated.rotation, 45.0);
      expect(updated.positionX, 1.0);
    });
  });

  // ────────────────────────────────────────────────────────────
  // BrandColor
  // ────────────────────────────────────────────────────────────
  group('BrandColor.toFirestore', () {
    test('includes name and hexValue', () {
      final c = BrandColor(
        id: 'c1',
        name: 'Navy',
        hexValue: '#1B2A4A',
        updatedAt: DateTime(2026),
      );
      final map = c.toFirestore();
      expect(map['name'], 'Navy');
      expect(map['hexValue'], '#1B2A4A');
    });

    test('updatedAt is serialised as a Timestamp', () {
      final dt = DateTime(2026, 4, 1);
      final c = BrandColor(id: 'c1', name: 'Red', hexValue: '#FF0000', updatedAt: dt);
      expect((c.toFirestore()['updatedAt'] as Timestamp).toDate(), dt);
    });
  });

  // ────────────────────────────────────────────────────────────
  // MannequinOutfitSlot
  // ────────────────────────────────────────────────────────────
  group('MannequinOutfitSlot.toFirestore', () {
    test('includes bodySlot and mannequinId', () {
      final slot = MannequinOutfitSlot(
        id: 's1',
        mannequinId: 'm1',
        bodySlot: 'torso',
        productId: 'p1',
        updatedAt: DateTime(2026),
      );
      final map = slot.toFirestore();
      expect(map['mannequinId'], 'm1');
      expect(map['bodySlot'], 'torso');
      expect(map['productId'], 'p1');
    });

    test('omits null productId', () {
      final slot = MannequinOutfitSlot(
        id: 's1',
        mannequinId: 'm1',
        bodySlot: 'head',
        updatedAt: DateTime(2026),
      );
      final map = slot.toFirestore();
      expect(map.containsKey('productId'), isFalse);
    });

    test('omits null colorId and notes', () {
      final slot = MannequinOutfitSlot(
        id: 's1',
        mannequinId: 'm1',
        bodySlot: 'feet',
        updatedAt: DateTime(2026),
      );
      final map = slot.toFirestore();
      expect(map.containsKey('colorId'), isFalse);
      expect(map.containsKey('colorNotes'), isFalse);
      expect(map.containsKey('displayNotes'), isFalse);
    });

    test('includes colorId and notes when set', () {
      final slot = MannequinOutfitSlot(
        id: 's1',
        mannequinId: 'm1',
        bodySlot: 'legs',
        productId: 'p2',
        colorId: 'col1',
        colorNotes: 'Dark wash',
        displayNotes: 'Cuffed',
        updatedAt: DateTime(2026),
      );
      final map = slot.toFirestore();
      expect(map['colorId'], 'col1');
      expect(map['colorNotes'], 'Dark wash');
      expect(map['displayNotes'], 'Cuffed');
    });
  });

  group('MannequinOutfitSlot.copyWith', () {
    final base = MannequinOutfitSlot(
      id: 's1',
      mannequinId: 'm1',
      bodySlot: 'torso',
      updatedAt: DateTime(2026),
    );

    test('preserves id and mannequinId', () {
      final updated = base.copyWith(productId: 'p1');
      expect(updated.id, 's1');
      expect(updated.mannequinId, 'm1');
      expect(updated.bodySlot, 'torso');
    });

    test('updates productId', () {
      final updated = base.copyWith(productId: 'p99');
      expect(updated.productId, 'p99');
    });
  });

  // ────────────────────────────────────────────────────────────
  // PlatformElement
  // ────────────────────────────────────────────────────────────
  group('PlatformElement.toFirestore', () {
    test('includes dimensions and position', () {
      final p = PlatformElement(
        id: 'p1',
        storeId: 's1',
        zoneId: 'z1',
        width: 4.0,
        depth: 3.0,
        elevation: 0.5,
        positionX: 2.0,
        positionY: 1.0,
        updatedAt: DateTime(2026),
      );
      final map = p.toFirestore();
      expect(map['width'], 4.0);
      expect(map['depth'], 3.0);
      expect(map['elevation'], 0.5);
      expect(map['positionX'], 2.0);
      expect(map['positionY'], 1.0);
      expect(map['storeId'], 's1');
      expect(map['zoneId'], 'z1');
    });

    test('includes default colorHex when not overridden', () {
      final p = PlatformElement(
        id: 'p1',
        storeId: 's1',
        zoneId: 'z1',
        width: 2.0,
        depth: 2.0,
        elevation: 0.0,
        positionX: 0,
        positionY: 0,
        updatedAt: DateTime(2026),
      );
      expect(p.toFirestore()['colorHex'], '#CCCCCC');
    });

    test('custom colorHex is written', () {
      final p = PlatformElement(
        id: 'p1',
        storeId: 's1',
        zoneId: 'z1',
        width: 2.0,
        depth: 2.0,
        elevation: 0.0,
        positionX: 0,
        positionY: 0,
        colorHex: '#3A3A3A',
        updatedAt: DateTime(2026),
      );
      expect(p.toFirestore()['colorHex'], '#3A3A3A');
    });
  });

  // ────────────────────────────────────────────────────────────
  // SceneProp
  // ────────────────────────────────────────────────────────────
  group('SceneProp.toFirestore', () {
    test('includes propType and name', () {
      final prop = SceneProp(
        id: 'p1',
        storeId: 's1',
        zoneId: 'z1',
        propType: 'plant',
        name: 'Ficus',
        positionX: 0,
        positionY: 0,
        width: 2.0,
        depth: 2.0,
        updatedAt: DateTime(2026),
      );
      final map = prop.toFirestore();
      expect(map['propType'], 'plant');
      expect(map['name'], 'Ficus');
    });

    test('includes all spatial fields', () {
      final prop = SceneProp(
        id: 'p1',
        storeId: 's1',
        zoneId: 'z1',
        propType: 'signage',
        name: 'Sale Sign',
        positionX: 5.0,
        positionY: 6.5,
        rotation: 45.0,
        width: 1.0,
        depth: 0.5,
        updatedAt: DateTime(2026),
      );
      final map = prop.toFirestore();
      expect(map['positionX'], 5.0);
      expect(map['positionY'], 6.5);
      expect(map['rotation'], 45.0);
      expect(map['width'], 1.0);
      expect(map['depth'], 0.5);
    });

    test('copyWith preserves storeId and zoneId', () {
      final prop = SceneProp(
        id: 'p1',
        storeId: 's1',
        zoneId: 'z1',
        propType: 'furniture',
        name: 'Chair',
        positionX: 0,
        positionY: 0,
        width: 1.0,
        depth: 1.0,
        updatedAt: DateTime(2026),
      );
      final updated = prop.copyWith(name: 'Bench');
      expect(updated.storeId, 's1');
      expect(updated.zoneId, 'z1');
      expect(updated.name, 'Bench');
      expect(updated.propType, 'furniture');
    });
  });
}
