import 'package:uuid/uuid.dart';
import 'garment_item.dart';
import 'mannequin_look.dart';
import 'decorative_element.dart';
import 'store_zone.dart';
import 'wall_arm_template.dart';

enum SectionType { perimeter, table, floorRack }

extension SectionTypeX on SectionType {
  String get displayName => switch (this) {
        SectionType.perimeter => 'Perimeter Wall',
        SectionType.table => 'Table',
        SectionType.floorRack => 'Floor Rack',
      };

  String get icon => switch (this) {
        SectionType.perimeter => '🧱',
        SectionType.table => '📋',
        SectionType.floorRack => '🎣',
      };
}

class DisplaySection {
  final String id;
  final String title;
  final SectionType type;

  /// Garments in this section. For tables these are folded; for racks, hanging.
  final List<GarmentItem> garments;

  /// Optional mannequin look associated with this section.
  final MannequinLook? mannequinLook;

  /// Decorative elements (plants, standalone mannequins) placed in/near section.
  final List<DecorativeElement> decorativeElements;

  /// Wall-specific: linear footage (e.g., 8, 24).
  final int? linearFeet;

  /// Wall-specific: number of items displayed face-out per bay (default 2).
  final int faceOutCount;

  /// Wall-specific: number of items on a U-bar/shoulder-out per bay (default 3).
  final int uBarCount;

  /// Section transition notes shown at left/right margins.
  final String? previousSectionNote;
  final String? nextSectionNote;

  // ── Store layout positioning ───────────────────────────────────────────────

  /// Which wall this section is on (for perimeter sections).
  final WallSide wallSide;

  /// Normalised position on the wall or floor (0.0–1.0).
  /// For wall sections: position along the wall (0 = left end, 1 = right end).
  /// For floor sections: (layoutX, layoutY) position in the store.
  final double layoutPosition;
  final double layoutX;
  final double layoutY;

  /// ID of the zone this section belongs to (null = unassigned).
  final String? zoneId;

  /// Arm assignments from a wall arm template auto-fill.
  /// When non-null, the wall renders arm-by-arm with color-triangle layout.
  final List<ArmAssignment>? armAssignments;

  DisplaySection({
    String? id,
    required this.title,
    required this.type,
    this.garments = const [],
    this.mannequinLook,
    this.decorativeElements = const [],
    this.linearFeet,
    this.faceOutCount = 2,
    this.uBarCount = 3,
    this.previousSectionNote,
    this.wallSide = WallSide.none,
    this.layoutPosition = 0.0,
    this.layoutX = 0.5,
    this.layoutY = 0.5,
    this.zoneId,
    this.nextSectionNote,
    this.armAssignments,
  }) : id = id ?? const Uuid().v4();

  DisplaySection copyWith({
    String? title,
    SectionType? type,
    List<GarmentItem>? garments,
    MannequinLook? mannequinLook,
    List<DecorativeElement>? decorativeElements,
    int? linearFeet,
    int? faceOutCount,
    int? uBarCount,
    String? previousSectionNote,
    String? nextSectionNote,
    WallSide? wallSide,
    double? layoutPosition,
    double? layoutX,
    double? layoutY,
    String? zoneId,
    List<ArmAssignment>? armAssignments,
    bool clearMannequin = false,
    bool clearZone = false,
    bool clearArmAssignments = false,
  }) {
    return DisplaySection(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      garments: garments ?? this.garments,
      mannequinLook:
          clearMannequin ? null : (mannequinLook ?? this.mannequinLook),
      decorativeElements: decorativeElements ?? this.decorativeElements,
      linearFeet: linearFeet ?? this.linearFeet,
      faceOutCount: faceOutCount ?? this.faceOutCount,
      uBarCount: uBarCount ?? this.uBarCount,
      previousSectionNote: previousSectionNote ?? this.previousSectionNote,
      nextSectionNote: nextSectionNote ?? this.nextSectionNote,
      wallSide: wallSide ?? this.wallSide,
      layoutPosition: layoutPosition ?? this.layoutPosition,
      layoutX: layoutX ?? this.layoutX,
      layoutY: layoutY ?? this.layoutY,
      zoneId: clearZone ? null : (zoneId ?? this.zoneId),
      armAssignments: clearArmAssignments
          ? null
          : (armAssignments ?? this.armAssignments),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'garments': garments.map((g) => g.toJson()).toList(),
        'mannequinLook': mannequinLook?.toJson(),
        'decorativeElements':
            decorativeElements.map((d) => d.toJson()).toList(),
        'linearFeet': linearFeet,
        'faceOutCount': faceOutCount,
        'uBarCount': uBarCount,
        'previousSectionNote': previousSectionNote,
        'nextSectionNote': nextSectionNote,
        'wallSide': wallSide.name,
        'layoutPosition': layoutPosition,
        'layoutX': layoutX,
        'layoutY': layoutY,
        'zoneId': zoneId,
        'armAssignments': armAssignments?.map((a) => a.toJson()).toList(),
      };

  factory DisplaySection.fromJson(Map<String, dynamic> json) => DisplaySection(
        id: json['id'] as String,
        title: json['title'] as String,
        type: SectionType.values.byName(json['type'] as String),
        garments: (json['garments'] as List)
            .map((g) => GarmentItem.fromJson(g as Map<String, dynamic>))
            .toList(),
        mannequinLook: json['mannequinLook'] != null
            ? MannequinLook.fromJson(
                json['mannequinLook'] as Map<String, dynamic>)
            : null,
        decorativeElements: (json['decorativeElements'] as List? ?? [])
            .map((d) =>
                DecorativeElement.fromJson(d as Map<String, dynamic>))
            .toList(),
        linearFeet: json['linearFeet'] as int?,
        faceOutCount: json['faceOutCount'] as int? ?? 2,
        uBarCount: json['uBarCount'] as int? ?? 3,
        previousSectionNote: json['previousSectionNote'] as String?,
        nextSectionNote: json['nextSectionNote'] as String?,
        wallSide: json['wallSide'] != null
            ? WallSide.values.byName(json['wallSide'] as String)
            : WallSide.none,
        layoutPosition: (json['layoutPosition'] as num?)?.toDouble() ?? 0.0,
        layoutX: (json['layoutX'] as num?)?.toDouble() ?? 0.5,
        layoutY: (json['layoutY'] as num?)?.toDouble() ?? 0.5,
        zoneId: json['zoneId'] as String?,
        armAssignments: (json['armAssignments'] as List?)
            ?.map((a) => ArmAssignment.fromJson(a as Map<String, dynamic>))
            .toList(),
      );
}
