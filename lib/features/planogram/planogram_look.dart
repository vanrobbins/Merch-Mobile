import 'dart:convert';

import 'package:uuid/uuid.dart';

/// A mannequin outfit callout stored inside a planogram.
/// Represents "here's a look we're highlighting on this wall section."
class PlanogramLook {
  const PlanogramLook({
    required this.id,
    required this.mannequinType,
    required this.outfitName,
    this.notes = '',
  });

  final String id;
  // full_body | half_body | torso | leg_form | bra_form | bag_stand | hat_stand
  final String mannequinType;
  final String outfitName;
  final String notes;

  PlanogramLook copyWith({
    String? mannequinType,
    String? outfitName,
    String? notes,
  }) => PlanogramLook(
    id: id,
    mannequinType: mannequinType ?? this.mannequinType,
    outfitName: outfitName ?? this.outfitName,
    notes: notes ?? this.notes,
  );

  static PlanogramLook create({
    required String mannequinType,
    required String outfitName,
    String notes = '',
  }) => PlanogramLook(
    id: const Uuid().v4(),
    mannequinType: mannequinType,
    outfitName: outfitName,
    notes: notes,
  );

  static List<PlanogramLook> decodeList(String json) {
    if (json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => PlanogramLook(
        id: e['id'] as String,
        mannequinType: e['type'] as String? ?? 'full_body',
        outfitName: e['name'] as String? ?? '',
        notes: e['notes'] as String? ?? '',
      )).toList();
    } catch (_) {
      return [];
    }
  }

  static String encodeList(List<PlanogramLook> looks) => jsonEncode(
    looks.map((l) => {
      'id': l.id,
      'type': l.mannequinType,
      'name': l.outfitName,
      'notes': l.notes,
    }).toList(),
  );
}
