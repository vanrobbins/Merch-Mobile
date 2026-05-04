import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/models/mannequin_outfit_slot.dart';
import 'package:merch_mobile/core/models/product.dart';
import 'package:merch_mobile/features/zone_manager/mannequin_lock_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  // ── shared fixtures ─────────────────────────────────────────────────────────

  final kSlotTorso = MannequinOutfitSlot(
    id: 's1',
    mannequinId: 'm1',
    bodySlot: 'torso',
    productId: 'p1',
    updatedAt: DateTime(2026, 4, 28),
  );

  final kSlotHead = MannequinOutfitSlot(
    id: 's2',
    mannequinId: 'm1',
    bodySlot: 'head',
    // no productId — unfilled slot
    updatedAt: DateTime(2026, 4, 28),
  );

  final kProduct = Product(
    id: 'p1',
    sku: 'SKU001',
    name: 'White Tee',
    category: 'Tops',
    stockQty: 10,
    updatedAt: DateTime(2026, 4, 28),
  );

  // ── outfit name display ──────────────────────────────────────────────────────

  group('MannequinLockCard outfit name', () {
    testWidgets('shows outfitName when non-empty', (tester) async {
      await tester.pumpWidget(_wrap(const MannequinLockCard(
        outfitName: 'Summer Look',
        slots: [],
        products: [],
      )));
      expect(find.text('Summer Look'), findsOneWidget);
    });

    testWidgets('shows UNNAMED OUTFIT when outfitName is empty', (tester) async {
      await tester.pumpWidget(_wrap(const MannequinLockCard(
        outfitName: '',
        slots: [],
        products: [],
      )));
      expect(find.text('UNNAMED OUTFIT'), findsOneWidget);
    });
  });

  // ── empty slots ──────────────────────────────────────────────────────────────

  group('MannequinLockCard empty state', () {
    testWidgets('shows "No outfit" when slot list is empty', (tester) async {
      await tester.pumpWidget(_wrap(const MannequinLockCard(
        outfitName: 'Summer Look',
        slots: [],
        products: [],
      )));
      expect(find.text('No outfit'), findsOneWidget);
    });

    testWidgets('shows "No outfit" when all slots have null productId',
        (tester) async {
      await tester.pumpWidget(_wrap(MannequinLockCard(
        outfitName: 'Summer Look',
        slots: [kSlotHead], // head slot has no productId
        products: const [],
      )));
      expect(find.text('No outfit'), findsOneWidget);
    });
  });

  // ── filled slots ─────────────────────────────────────────────────────────────

  group('MannequinLockCard filled slots', () {
    testWidgets('shows slot label for filled slot', (tester) async {
      await tester.pumpWidget(_wrap(MannequinLockCard(
        outfitName: 'Summer Look',
        slots: [kSlotTorso],
        products: [kProduct],
      )));
      await tester.pump();
      // bodySlot 'torso' → 'TORSO'
      expect(find.text('TORSO'), findsOneWidget);
    });

    testWidgets('shows SKU and name for resolved product', (tester) async {
      await tester.pumpWidget(_wrap(MannequinLockCard(
        outfitName: 'Summer Look',
        slots: [kSlotTorso],
        products: [kProduct],
      )));
      await tester.pump();
      // productLabel = 'SKU001 — White Tee'
      expect(find.text('SKU001 — White Tee'), findsOneWidget);
    });

    testWidgets('shows productId when product is not in list', (tester) async {
      await tester.pumpWidget(_wrap(MannequinLockCard(
        outfitName: 'Summer Look',
        slots: [kSlotTorso],
        products: const [], // product list is empty
      )));
      await tester.pump();
      // Falls back to the raw productId
      expect(find.text('p1'), findsOneWidget);
    });

    testWidgets('does not show "No outfit" when at least one slot is filled',
        (tester) async {
      await tester.pumpWidget(_wrap(MannequinLockCard(
        outfitName: 'Summer Look',
        slots: [kSlotTorso],
        products: [kProduct],
      )));
      await tester.pump();
      expect(find.text('No outfit'), findsNothing);
    });
  });

  // ── underscore label formatting ──────────────────────────────────────────────

  group('MannequinLockCard slot label formatting', () {
    testWidgets('converts underscore bodySlot to spaced ALL CAPS label',
        (tester) async {
      final leftHandSlot = MannequinOutfitSlot(
        id: 's3',
        mannequinId: 'm1',
        bodySlot: 'left_hand',
        productId: 'p1',
        updatedAt: DateTime(2026, 4, 28),
      );

      await tester.pumpWidget(_wrap(MannequinLockCard(
        outfitName: 'Glove Look',
        slots: [leftHandSlot],
        products: [kProduct],
      )));
      await tester.pump();
      // 'left_hand' → 'LEFT HAND'
      expect(find.text('LEFT HAND'), findsOneWidget);
    });
  });

  // ── multiple slots ───────────────────────────────────────────────────────────

  group('MannequinLockCard multiple slots', () {
    testWidgets('renders all filled slots', (tester) async {
      final legsProduct = Product(
        id: 'p2',
        sku: 'SKU002',
        name: 'Slim Jeans',
        category: 'Bottoms',
        stockQty: 5,
        updatedAt: DateTime(2026, 4, 28),
      );
      final legsSlot = MannequinOutfitSlot(
        id: 's4',
        mannequinId: 'm1',
        bodySlot: 'legs',
        productId: 'p2',
        updatedAt: DateTime(2026, 4, 28),
      );

      await tester.pumpWidget(_wrap(MannequinLockCard(
        outfitName: 'Full Look',
        slots: [kSlotTorso, legsSlot],
        products: [kProduct, legsProduct],
      )));
      await tester.pump();

      expect(find.text('TORSO'), findsOneWidget);
      expect(find.text('LEGS'), findsOneWidget);
      expect(find.text('SKU001 — White Tee'), findsOneWidget);
      expect(find.text('SKU002 — Slim Jeans'), findsOneWidget);
    });

    testWidgets('unfilled slots are hidden from the list', (tester) async {
      // kSlotHead has no productId — should not appear
      await tester.pumpWidget(_wrap(MannequinLockCard(
        outfitName: 'Full Look',
        slots: [kSlotTorso, kSlotHead],
        products: [kProduct],
      )));
      await tester.pump();

      expect(find.text('TORSO'), findsOneWidget);
      expect(find.text('HEAD'), findsNothing);
    });
  });
}
