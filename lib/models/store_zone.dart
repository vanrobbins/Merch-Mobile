import 'package:uuid/uuid.dart';

/// A named zone in the store floor plan (e.g. "Women's", "Entrance", "Back Wall").
/// Zones group multiple display sections together visually on the floor plan.
class StoreZone {
  final String id;
  final String name;

  /// Zone color as ARGB int (for floor plan highlight and labels).
  final int colorValue;

  /// Section IDs assigned to this zone.
  final List<String> sectionIds;

  StoreZone({
    String? id,
    required this.name,
    required this.colorValue,
    this.sectionIds = const [],
  }) : id = id ?? const Uuid().v4();

  StoreZone copyWith({
    String? name,
    int? colorValue,
    List<String>? sectionIds,
  }) {
    return StoreZone(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      sectionIds: sectionIds ?? this.sectionIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'sectionIds': sectionIds,
      };

  factory StoreZone.fromJson(Map<String, dynamic> json) => StoreZone(
        id: json['id'] as String,
        name: json['name'] as String,
        colorValue: json['colorValue'] as int,
        sectionIds: (json['sectionIds'] as List? ?? [])
            .map((e) => e as String)
            .toList(),
      );

  // ── Preset zone colors ────────────────────────────────────────────────────

  static const List<int> presetColors = [
    0xFF3B6BC2, // blue
    0xFFCC2222, // red
    0xFF3A7D44, // green
    0xFFC19A6B, // tan
    0xFF8B3D8B, // purple
    0xFFE07B54, // orange
    0xFF2D8B8B, // teal
    0xFFB5A020, // gold
    0xFF555555, // charcoal
    0xFF90B8CC, // sky
  ];
}

/// Wall side enum for positioning perimeter sections on the store floor plan.
enum WallSide { north, south, east, west, none }

extension WallSideX on WallSide {
  String get displayName => switch (this) {
        WallSide.north => 'North Wall',
        WallSide.south => 'South Wall',
        WallSide.east => 'East Wall',
        WallSide.west => 'West Wall',
        WallSide.none => 'Floor / Unassigned',
      };
  String get shortName => switch (this) {
        WallSide.north => 'N',
        WallSide.south => 'S',
        WallSide.east => 'E',
        WallSide.west => 'W',
        WallSide.none => '—',
      };
}
