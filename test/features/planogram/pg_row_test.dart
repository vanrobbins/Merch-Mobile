import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/planogram/pg_row.dart';

void main() {
  group('PgRow.fromJson / toJson round-trip', () {
    test('bar row round-trips', () {
      const row = PgRow(index: 0, rowType: 'bar', label: 'Tops');
      final restored = PgRow.fromJson(row.toJson());
      expect(restored.index, 0);
      expect(restored.rowType, 'bar');
      expect(restored.label, 'Tops');
    });

    test('shelf row round-trips', () {
      const row = PgRow(index: 2, rowType: 'shelf');
      final restored = PgRow.fromJson(row.toJson());
      expect(restored.rowType, 'shelf');
      expect(restored.label, isNull);
    });

    test('missing rowType defaults to bar', () {
      final restored = PgRow.fromJson({'index': 1});
      expect(restored.rowType, 'bar');
    });
  });

  group('PgRow.encodeList / decodeList', () {
    test('empty string returns empty list', () {
      expect(PgRow.decodeList(''), isEmpty);
    });

    test('round-trips 3 rows', () {
      final rows = PgRow.defaults(3, 'wall');
      expect(rows.length, 3);
      final json = PgRow.encodeList(rows);
      final restored = PgRow.decodeList(json);
      expect(restored.length, 3);
      expect(restored[0].rowType, 'bar');
      expect(restored[2].index, 2);
    });
  });

  group('PgRow.defaults', () {
    test('wall planogram defaults all rows to bar', () {
      final rows = PgRow.defaults(4, 'wall');
      expect(rows.every((r) => r.rowType == 'bar'), isTrue);
    });

    test('table planogram defaults all rows to shelf', () {
      final rows = PgRow.defaults(2, 'table');
      expect(rows.every((r) => r.rowType == 'shelf'), isTrue);
    });

    test('generates sequential indices', () {
      final rows = PgRow.defaults(3, 'shelf');
      expect(rows.map((r) => r.index).toList(), [0, 1, 2]);
    });
  });

  group('PgRow.copyWith', () {
    test('changes rowType while preserving other fields', () {
      const row = PgRow(index: 1, rowType: 'bar', label: 'Mid');
      final toggled = row.copyWith(rowType: 'shelf');
      expect(toggled.rowType, 'shelf');
      expect(toggled.index, 1);
      expect(toggled.label, 'Mid');
    });
  });
}
