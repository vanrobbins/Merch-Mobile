import 'package:uuid/uuid.dart';
import 'garment_item.dart';
import 'mannequin_look.dart';
import 'decorative_element.dart';

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
    this.nextSectionNote,
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
    bool clearMannequin = false,
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
      );
}
