import 'package:uuid/uuid.dart';
import 'store_zone.dart';
import 'display_section.dart';

/// A reusable store layout template: store dimensions + zone definitions.
/// Templates do NOT contain garment data — only the structural layout.
class StoreTemplate {
  final String id;
  final String name;
  final double storeWidthFt;
  final double storeDepthFt;

  /// Zone definitions (names, colors, positions).
  final List<StoreZone> zones;

  /// Skeleton sections (type + title + wall assignment, no garments).
  final List<TemplateSectionStub> sectionStubs;

  StoreTemplate({
    String? id,
    required this.name,
    required this.storeWidthFt,
    required this.storeDepthFt,
    this.zones = const [],
    this.sectionStubs = const [],
  }) : id = id ?? const Uuid().v4();

  StoreTemplate copyWith({
    String? name,
    double? storeWidthFt,
    double? storeDepthFt,
    List<StoreZone>? zones,
    List<TemplateSectionStub>? sectionStubs,
  }) {
    return StoreTemplate(
      id: id,
      name: name ?? this.name,
      storeWidthFt: storeWidthFt ?? this.storeWidthFt,
      storeDepthFt: storeDepthFt ?? this.storeDepthFt,
      zones: zones ?? this.zones,
      sectionStubs: sectionStubs ?? this.sectionStubs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'storeWidthFt': storeWidthFt,
        'storeDepthFt': storeDepthFt,
        'zones': zones.map((z) => z.toJson()).toList(),
        'sectionStubs': sectionStubs.map((s) => s.toJson()).toList(),
      };

  factory StoreTemplate.fromJson(Map<String, dynamic> json) => StoreTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        storeWidthFt: (json['storeWidthFt'] as num).toDouble(),
        storeDepthFt: (json['storeDepthFt'] as num).toDouble(),
        zones: (json['zones'] as List? ?? [])
            .map((z) => StoreZone.fromJson(z as Map<String, dynamic>))
            .toList(),
        sectionStubs: (json['sectionStubs'] as List? ?? [])
            .map((s) => TemplateSectionStub.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  /// Create a template from an existing project (strips garment data).
  factory StoreTemplate.fromProject(
    String templateName, {
    required String projectId,
    required double widthFt,
    required double depthFt,
    required List<StoreZone> zones,
    required List<DisplaySection> sections,
  }) {
    return StoreTemplate(
      name: templateName,
      storeWidthFt: widthFt,
      storeDepthFt: depthFt,
      zones: zones,
      sectionStubs: sections.map((s) => TemplateSectionStub(
            title: s.title,
            type: s.type,
            wallSide: s.wallSide,
            layoutPosition: s.layoutPosition,
            layoutX: s.layoutX,
            layoutY: s.layoutY,
            zoneId: s.zoneId,
            linearFeet: s.linearFeet,
            faceOutCount: s.faceOutCount,
            uBarCount: s.uBarCount,
          )).toList(),
    );
  }
}

/// A lightweight section skeleton stored in a template (no garments).
class TemplateSectionStub {
  final String title;
  final SectionType type;
  final WallSide wallSide;
  final double layoutPosition;
  final double layoutX;
  final double layoutY;
  final String? zoneId;
  final int? linearFeet;
  final int faceOutCount;
  final int uBarCount;

  const TemplateSectionStub({
    required this.title,
    required this.type,
    this.wallSide = WallSide.none,
    this.layoutPosition = 0.0,
    this.layoutX = 0.5,
    this.layoutY = 0.5,
    this.zoneId,
    this.linearFeet,
    this.faceOutCount = 2,
    this.uBarCount = 3,
  });

  /// Materialise into a full DisplaySection with no garments.
  DisplaySection toSection() => DisplaySection(
        title: title,
        type: type,
        wallSide: wallSide,
        layoutPosition: layoutPosition,
        layoutX: layoutX,
        layoutY: layoutY,
        zoneId: zoneId,
        linearFeet: linearFeet,
        faceOutCount: faceOutCount,
        uBarCount: uBarCount,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type.name,
        'wallSide': wallSide.name,
        'layoutPosition': layoutPosition,
        'layoutX': layoutX,
        'layoutY': layoutY,
        'zoneId': zoneId,
        'linearFeet': linearFeet,
        'faceOutCount': faceOutCount,
        'uBarCount': uBarCount,
      };

  factory TemplateSectionStub.fromJson(Map<String, dynamic> json) =>
      TemplateSectionStub(
        title: json['title'] as String,
        type: SectionType.values.byName(json['type'] as String),
        wallSide: json['wallSide'] != null
            ? WallSide.values.byName(json['wallSide'] as String)
            : WallSide.none,
        layoutPosition:
            (json['layoutPosition'] as num?)?.toDouble() ?? 0.0,
        layoutX: (json['layoutX'] as num?)?.toDouble() ?? 0.5,
        layoutY: (json['layoutY'] as num?)?.toDouble() ?? 0.5,
        zoneId: json['zoneId'] as String?,
        linearFeet: json['linearFeet'] as int?,
        faceOutCount: json['faceOutCount'] as int? ?? 2,
        uBarCount: json['uBarCount'] as int? ?? 3,
      );
}
