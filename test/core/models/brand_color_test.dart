import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/models/brand_color.dart';

void main() {
  group('BrandColor.copyWith', () {
    final base = BrandColor(
      id: 'c1',
      name: 'Navy',
      hexValue: '#1B2A4A',
      updatedAt: DateTime(2026, 4, 1),
    );

    test('preserves unchanged fields when only name changes', () {
      final updated = base.copyWith(name: 'Dark Navy');
      expect(updated.id, 'c1');
      expect(updated.hexValue, '#1B2A4A');
      expect(updated.name, 'Dark Navy');
      expect(updated.updatedAt, DateTime(2026, 4, 1));
    });

    test('can update hexValue without affecting name', () {
      final updated = base.copyWith(hexValue: '#000000');
      expect(updated.hexValue, '#000000');
      expect(updated.name, 'Navy');
      expect(updated.id, 'c1');
    });

    test('can update updatedAt', () {
      final newDate = DateTime(2026, 5, 1);
      final updated = base.copyWith(updatedAt: newDate);
      expect(updated.updatedAt, newDate);
      expect(updated.name, 'Navy');
      expect(updated.hexValue, '#1B2A4A');
    });

    test('can update all fields simultaneously', () {
      final newDate = DateTime(2026, 6, 1);
      final updated = base.copyWith(
        name: 'Midnight',
        hexValue: '#0A0A0A',
        updatedAt: newDate,
      );
      expect(updated.name, 'Midnight');
      expect(updated.hexValue, '#0A0A0A');
      expect(updated.updatedAt, newDate);
      expect(updated.id, 'c1'); // id is never changed by copyWith
    });

    test('no-arg copyWith returns equivalent object', () {
      final updated = base.copyWith();
      expect(updated.id, base.id);
      expect(updated.name, base.name);
      expect(updated.hexValue, base.hexValue);
      expect(updated.updatedAt, base.updatedAt);
    });
  });
}
