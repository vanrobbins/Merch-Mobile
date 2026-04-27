import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/zone_manager/zone_map_painter.dart';
import 'package:merch_mobile/features/zone_manager/store_entrance.dart';

void main() {
  group('ZoneMapPainter shouldRepaint', () {
    ZoneMapPainter makePainter({
      bool entranceEditMode = false,
      StoreEntrance? liveEntrance,
    }) =>
        ZoneMapPainter(
          zones: const [],
          canvasSize: const Size(400, 400),
          entranceEditMode: entranceEditMode,
          liveEntrance: liveEntrance,
        );

    test('repaint when entranceEditMode changes', () {
      final a = makePainter(entranceEditMode: false);
      final b = makePainter(entranceEditMode: true);
      expect(b.shouldRepaint(a), isTrue);
    });

    test('repaint when liveEntrance changes', () {
      final a = makePainter();
      final b = makePainter(
        liveEntrance: const StoreEntrance(wall: 0, pos: 0.5),
      );
      expect(b.shouldRepaint(a), isTrue);
    });

    test('no repaint when both unchanged', () {
      const entrance = StoreEntrance(wall: 0, pos: 0.5);
      final a = makePainter(entranceEditMode: true, liveEntrance: entrance);
      final b = makePainter(entranceEditMode: true, liveEntrance: entrance);
      expect(b.shouldRepaint(a), isFalse);
    });
  });
}
