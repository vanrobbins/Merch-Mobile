import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/floor_builder/undo_entry.dart';

void main() {
  group('UndoEntry', () {
    test('stores parallel before/after/ids lists', () {
      const entry = UndoEntry(
        before: [null, <String, dynamic>{'x': 1.0}],
        after: [<String, dynamic>{'x': 2.0}, null],
        ids: ['id1', 'id2'],
        collection: 'fixtures',
        label: 'Move 2 fixtures',
      );
      expect(entry.before.length, 2);
      expect(entry.after.length, 2);
      expect(entry.ids.length, 2);
      expect(entry.before[0], isNull);
      expect(entry.after[1], isNull);
    });

    test('add op has null before and non-null after', () {
      const entry = UndoEntry(
        before: [null],
        after: [<String, dynamic>{'id': 'f1', 'posX': 0.5}],
        ids: ['f1'],
        collection: 'fixtures',
        label: 'Add fixture',
      );
      expect(entry.before.first, isNull);
      expect(entry.after.first, isNotNull);
    });

    test('delete op has non-null before and null after', () {
      const entry = UndoEntry(
        before: [<String, dynamic>{'id': 'f1', 'posX': 0.5}],
        after: [null],
        ids: ['f1'],
        collection: 'fixtures',
        label: 'Delete fixture',
      );
      expect(entry.before.first, isNotNull);
      expect(entry.after.first, isNull);
    });
  });

  group('Stack cap at 20', () {
    // Simulate pushing 25 entries; only 20 should remain.
    test('oldest entry is dropped when stack exceeds 20', () {
      final stack = <UndoEntry>[];
      for (int i = 0; i < 25; i++) {
        if (stack.length >= 20) stack.removeAt(0);
        stack.add(UndoEntry(
          before: [null],
          after: [<String, dynamic>{'i': i}],
          ids: ['id$i'],
          collection: 'fixtures',
          label: 'Op $i',
        ));
      }
      expect(stack.length, 20);
      expect(stack.first.label, 'Op 5'); // ops 0-4 were dropped
      expect(stack.last.label, 'Op 24');
    });
  });
}
