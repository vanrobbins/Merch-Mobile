import 'package:cloud_firestore/cloud_firestore.dart';

/// A single reversible floor-builder operation.
///
/// [before] and [after] are parallel lists of Firestore doc maps (same length
/// as [ids]). null in [before] means the doc didn't exist yet (add op —
/// undo = delete). null in [after] means the doc was deleted (delete op —
/// undo = recreate from [before]).
class UndoEntry {
  final List<Map<String, dynamic>?> before;
  final List<Map<String, dynamic>?> after;
  final List<String> ids;
  final String collection; // 'fixtures' | 'mannequins' | 'platforms' | 'sceneProps'
  final String label;

  const UndoEntry({
    required this.before,
    required this.after,
    required this.ids,
    required this.collection,
    required this.label,
  });
}
