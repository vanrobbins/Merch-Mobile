import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/planogram/slot_sizing.dart';

void main() {
  group('hangLength', () {
    test('pants → 36"', () => expect(hangLength('pants'), 36));
    test('jeans → 36"', () => expect(hangLength('Jeans'), 36)); // case-insensitive
    test('dress → 48"', () => expect(hangLength('dress'), 48));
    test('coat → 48"', () => expect(hangLength('coat'), 48));
    test('jacket → 30"', () => expect(hangLength('jacket'), 30));
    test('hoodie → 30"', () => expect(hangLength('Hoodie'), 30));
    test('shirt → 30"', () => expect(hangLength('shirt'), 30));
    test('tee → 30"', () => expect(hangLength('tee'), 30));
    test('bra → 12"', () => expect(hangLength('bra'), 12));
    test('lingerie → 12"', () => expect(hangLength('lingerie'), 12));
    test('unknown → 18"', () => expect(hangLength('accessories'), 18));
  });

  group('foldedHeight', () {
    test('hoodie → 12"', () => expect(foldedHeight('hoodie'), 12));
    test('coat NOT in folded (falls to default 6")', () => expect(foldedHeight('coat'), 6));
    test('jacket → 10"', () => expect(foldedHeight('jacket'), 10));
    test('pants → 8"', () => expect(foldedHeight('pants'), 8));
    test('dress → 8"', () => expect(foldedHeight('dress'), 8));
    test('shirt → 6"', () => expect(foldedHeight('shirt'), 6));
    test('tee → 6"', () => expect(foldedHeight('tee'), 6));
    test('bra → 4"', () => expect(foldedHeight('bra'), 4));
    test('unknown → 6"', () => expect(foldedHeight('accessories'), 6));
  });

  group('autoSpanQuarters (rowHeight=24, quarterIn=6)', () {
    test('bra 12" → 2 quarters', () => expect(autoSpanQuarters('bra', 24.0), 2));
    test('shirt 30" → 5 quarters', () => expect(autoSpanQuarters('shirt', 24.0), 5));
    test('pants 36" → 6 quarters', () => expect(autoSpanQuarters('pants', 24.0), 6));
    test('dress 48" → 8 quarters', () => expect(autoSpanQuarters('dress', 24.0), 8));
    test('default 18" → 3 quarters', () => expect(autoSpanQuarters('accessories', 24.0), 3));
    test('minimum is 1', () => expect(autoSpanQuarters('bra', 100.0), 1));
  });

  group('shelfSpanQuarters (rowHeight=24, quarterIn=6, +1 clearance)', () {
    test('tee 6" → ceil(6/6)+1 = 2', () => expect(shelfSpanQuarters('tee', 24.0), 2));
    test('hoodie 12" → ceil(12/6)+1 = 3', () => expect(shelfSpanQuarters('hoodie', 24.0), 3));
    test('jacket 10" → ceil(10/6)+1 = 3', () => expect(shelfSpanQuarters('jacket', 24.0), 3));
    test('pants 8" → ceil(8/6)+1 = 3', () => expect(shelfSpanQuarters('pants', 24.0), 3));
    test('bra 4" → ceil(4/6)+1 = 2', () => expect(shelfSpanQuarters('bra', 24.0), 2));
    test('empty shelf → 2', () => expect(emptyShelfQuarters, 2));
  });
}
