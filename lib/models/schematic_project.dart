import 'package:uuid/uuid.dart';
import 'display_section.dart';
import 'store_zone.dart';

/// A single vertex of the store polygon, in normalised coordinates (0.0–1.0)
/// relative to the [storeWidthFt] × [storeDepthFt] bounding box.
class StorePoint {
  final double x;
  final double y;

  const StorePoint(this.x, this.y);

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
  factory StorePoint.fromJson(Map<String, dynamic> j) =>
      StorePoint((j['x'] as num).toDouble(), (j['y'] as num).toDouble());
}

/// Default rectangular store polygon (unit square).
const _defaultPolygon = [
  StorePoint(0, 0),
  StorePoint(1, 0),
  StorePoint(1, 1),
  StorePoint(0, 1),
];

class SchematicProject {
  final String id;
  final String name;
  final String? storeName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DisplaySection> sections;

  // ── Store layout settings ─────────────────────────────────────────────────

  /// Store bounding box width in feet (default 60ft).
  final double storeWidthFt;

  /// Store bounding box depth in feet (default 80ft).
  final double storeDepthFt;

  /// Polygon vertices defining the store footprint in normalised coordinates
  /// (0–1 relative to the bounding box). Defaults to a rectangle.
  /// Supports any simple polygon: L-shape, U-shape, irregular, etc.
  final List<StorePoint> storePolygon;

  /// Named zones that group display sections on the floor plan.
  final List<StoreZone> zones;

  SchematicProject({
    String? id,
    required this.name,
    this.storeName,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sections = const [],
    this.storeWidthFt = 60,
    this.storeDepthFt = 80,
    List<StorePoint>? storePolygon,
    this.zones = const [],
  }) : storePolygon = storePolygon ?? _defaultPolygon,
        id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  SchematicProject copyWith({
    String? name,
    String? storeName,
    List<DisplaySection>? sections,
    double? storeWidthFt,
    double? storeDepthFt,
    List<StorePoint>? storePolygon,
    List<StoreZone>? zones,
  }) {
    return SchematicProject(
      id: id,
      name: name ?? this.name,
      storeName: storeName ?? this.storeName,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      sections: sections ?? this.sections,
      storeWidthFt: storeWidthFt ?? this.storeWidthFt,
      storeDepthFt: storeDepthFt ?? this.storeDepthFt,
      storePolygon: storePolygon ?? this.storePolygon,
      zones: zones ?? this.zones,
    );
  }

  // ── Convenience helpers ───────────────────────────────────────────────────

  StoreZone? getZone(String zoneId) {
    try {
      return zones.firstWhere((z) => z.id == zoneId);
    } catch (_) {
      return null;
    }
  }

  List<DisplaySection> sectionsInZone(String zoneId) =>
      sections.where((s) => s.zoneId == zoneId).toList();

  List<DisplaySection> get unzonedSections =>
      sections.where((s) => s.zoneId == null).toList();

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'storeName': storeName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'sections': sections.map((s) => s.toJson()).toList(),
        'storeWidthFt': storeWidthFt,
        'storeDepthFt': storeDepthFt,
        'storePolygon': storePolygon.map((p) => p.toJson()).toList(),
        'zones': zones.map((z) => z.toJson()).toList(),
      };

  factory SchematicProject.fromJson(Map<String, dynamic> json) =>
      SchematicProject(
        id: json['id'] as String,
        name: json['name'] as String,
        storeName: json['storeName'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        sections: (json['sections'] as List)
            .map((s) => DisplaySection.fromJson(s as Map<String, dynamic>))
            .toList(),
        storeWidthFt: (json['storeWidthFt'] as num?)?.toDouble() ?? 60,
        storeDepthFt: (json['storeDepthFt'] as num?)?.toDouble() ?? 80,
        storePolygon: (json['storePolygon'] as List?)
            ?.map((p) => StorePoint.fromJson(p as Map<String, dynamic>))
            .toList(),
        zones: (json['zones'] as List? ?? [])
            .map((z) => StoreZone.fromJson(z as Map<String, dynamic>))
            .toList(),
      );
}
