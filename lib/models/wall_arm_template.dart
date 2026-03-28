import 'package:uuid/uuid.dart';

/// Type of arm/fixture in a wall section.
enum ArmType { faceOut, uBar, shelf2ft, shelf4ft }

extension ArmTypeX on ArmType {
  String get displayName => switch (this) {
        ArmType.faceOut => 'Face-Out',
        ArmType.uBar => 'U-Bar',
        ArmType.shelf2ft => '2ft Shelf',
        ArmType.shelf4ft => '4ft Shelf',
      };

  String get shortName => switch (this) {
        ArmType.faceOut => 'FO',
        ArmType.uBar => 'UB',
        ArmType.shelf2ft => 'S2',
        ArmType.shelf4ft => 'S4',
      };

  bool get isShelf => this == ArmType.shelf2ft || this == ArmType.shelf4ft;
  bool get isHanging => !isShelf;

  /// Default capacity for this arm type.
  int get defaultCapacity => switch (this) {
        ArmType.faceOut => 2,
        ArmType.uBar => 3,
        ArmType.shelf2ft => 4,
        ArmType.shelf4ft => 8,
      };

  int get widthFt => switch (this) {
        ArmType.shelf2ft => 2,
        ArmType.shelf4ft => 4,
        _ => 2,
      };
}

/// A single arm or shelf slot on a wall section.
class WallArm {
  final ArmType type;
  final int capacity;
  final String? label;

  const WallArm({
    required this.type,
    required this.capacity,
    this.label,
  });

  WallArm copyWith({ArmType? type, int? capacity, String? label}) => WallArm(
        type: type ?? this.type,
        capacity: capacity ?? this.capacity,
        label: label ?? this.label,
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'capacity': capacity,
        'label': label,
      };

  factory WallArm.fromJson(Map<String, dynamic> json) => WallArm(
        type: ArmType.values.byName(json['type'] as String),
        capacity: json['capacity'] as int,
        label: json['label'] as String?,
      );
}

/// Per-arm garment assignment produced by auto-fill.
class ArmAssignment {
  final int armIndex;
  final ArmType armType;
  final int capacity;
  final String? garmentId;

  /// Which colorway index of the garment to display on this arm.
  final int colorwayIndex;

  const ArmAssignment({
    required this.armIndex,
    required this.armType,
    required this.capacity,
    this.garmentId,
    this.colorwayIndex = 0,
  });

  ArmAssignment copyWith({
    String? garmentId,
    int? colorwayIndex,
    int? capacity,
  }) =>
      ArmAssignment(
        armIndex: armIndex,
        armType: armType,
        capacity: capacity ?? this.capacity,
        garmentId: garmentId ?? this.garmentId,
        colorwayIndex: colorwayIndex ?? this.colorwayIndex,
      );

  Map<String, dynamic> toJson() => {
        'armIndex': armIndex,
        'armType': armType.name,
        'capacity': capacity,
        'garmentId': garmentId,
        'colorwayIndex': colorwayIndex,
      };

  factory ArmAssignment.fromJson(Map<String, dynamic> json) => ArmAssignment(
        armIndex: json['armIndex'] as int,
        armType: ArmType.values.byName(json['armType'] as String),
        capacity: json['capacity'] as int,
        garmentId: json['garmentId'] as String?,
        colorwayIndex: json['colorwayIndex'] as int? ?? 0,
      );
}

/// A reusable wall arm layout template (sequence of arms/shelves).
class WallArmTemplate {
  final String id;
  final String name;
  final List<WallArm> arms;

  WallArmTemplate({
    String? id,
    required this.name,
    required this.arms,
  }) : id = id ?? const Uuid().v4();

  int get totalCapacity => arms.fold(0, (s, a) => s + a.capacity);
  int get faceOutArmCount => arms.where((a) => a.type == ArmType.faceOut).length;
  int get uBarArmCount => arms.where((a) => a.type == ArmType.uBar).length;
  int get shelfArmCount => arms.where((a) => a.type.isShelf).length;
  int get hangingArmCount => arms.where((a) => a.type.isHanging).length;

  WallArmTemplate copyWith({String? name, List<WallArm>? arms}) =>
      WallArmTemplate(
          id: id, name: name ?? this.name, arms: arms ?? this.arms);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'arms': arms.map((a) => a.toJson()).toList(),
      };

  factory WallArmTemplate.fromJson(Map<String, dynamic> json) =>
      WallArmTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        arms: (json['arms'] as List)
            .map((a) => WallArm.fromJson(a as Map<String, dynamic>))
            .toList(),
      );

  /// Generate arm assignments for [garment] using color-triangle distribution.
  ///
  /// Color triangle: colorways are mirrored across the arm sequence so the
  /// same color appears at both ends and key midpoints — the standard VM
  /// "triangle" technique that draws the customer's eye across the wall.
  ///
  /// Example — 3 colorways (A,B,C) across 6 arms: A B C C B A
  /// Example — 2 colorways (A,B) across 4 arms:    A B B A
  /// Example — 1 colorway  (A)   across any arms:  A A A A
  List<ArmAssignment> autoFill(
    String garmentId,
    List<int> availableColorwayIndices,
  ) {
    final cwCount = availableColorwayIndices.isEmpty
        ? 1
        : availableColorwayIndices.length;
    final assignments = <ArmAssignment>[];

    int hangingArmsSeen = 0;

    for (int i = 0; i < arms.length; i++) {
      final arm = arms[i];
      int cwIdx;

      if (arm.type.isShelf) {
        // Shelves: use the first colorway (full colorway rainbow shown by widget)
        cwIdx = availableColorwayIndices.isNotEmpty
            ? availableColorwayIndices[0]
            : 0;
      } else {
        // Hanging arms: apply color-triangle (mirrored pattern)
        final hangingTotal = hangingArmCount;
        cwIdx = triangleColorwayIndex(
            hangingArmsSeen, hangingTotal, cwCount, availableColorwayIndices);
        hangingArmsSeen++;
      }

      assignments.add(ArmAssignment(
        armIndex: i,
        armType: arm.type,
        capacity: arm.capacity,
        garmentId: garmentId,
        colorwayIndex: cwIdx,
      ));
    }

    return assignments;
  }

  /// Maps arm position [pos] within [total] arms to a colorway index using
  /// a mirror (chevron) pattern.
  /// Mirror (chevron) colorway index: same color appears at both ends of
  /// the arm sequence. Pattern for k=3: [0,1,2,1,0,1,2,1,...]
  static int triangleColorwayIndex(
    int pos,
    int total,
    int cwCount,
    List<int> cwIndices,
  ) {
    if (cwCount <= 1 || cwIndices.isEmpty) {
      return cwIndices.isNotEmpty ? cwIndices[0] : 0;
    }
    // Period = 2*(cwCount-1) gives palindrome: 0,1,2,...,k-1,k-2,...,1
    final mirrorLen = (cwCount * 2 - 2).clamp(1, 999);
    final cyclePos = pos % mirrorLen;
    final rawIdx =
        cyclePos < cwCount ? cyclePos : mirrorLen - cyclePos;
    return cwIndices[rawIdx.clamp(0, cwIndices.length - 1)];
  }
}
