import 'dart:convert';
import 'dart:ui';

/// Describes a gap (entrance) cut into the store boundary rectangle.
///
/// Walls: 0 = bottom, 1 = right, 2 = top, 3 = left.
/// [pos] is the centre of the gap as a fraction (0–1) along the wall.
/// [widthFrac] is the gap width as a fraction of the wall length.
class StoreEntrance {
  const StoreEntrance({
    required this.wall,
    required this.pos,
    this.widthFrac = 0.15,
  });

  final int wall;
  final double pos;
  final double widthFrac;

  static const wallNames = ['Bottom', 'Right', 'Top', 'Left'];
  String get wallName => wallNames[wall.clamp(0, 3)];

  static StoreEntrance? fromJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return StoreEntrance(
        wall: (m['wall'] as num).toInt(),
        pos: (m['pos'] as num).toDouble(),
        widthFrac: (m['widthFrac'] as num? ?? 0.15).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  String toJson() =>
      jsonEncode({'wall': wall, 'pos': pos, 'widthFrac': widthFrac});

  StoreEntrance copyWith({int? wall, double? pos, double? widthFrac}) =>
      StoreEntrance(
        wall: wall ?? this.wall,
        pos: pos ?? this.pos,
        widthFrac: widthFrac ?? this.widthFrac,
      );

  /// Builds a boundary [Path] for [rect] with this entrance cut out.
  /// Pass [pixelsPerFt] and [wallFt] to label the gap width in feet (unused in path).
  static Path boundaryPath(Rect rect, StoreEntrance? entrance) {
    if (entrance == null) return Path()..addRect(rect);

    final path = Path();

    // Define 4 wall segments: (from, to) drawn in order TL→TR→BR→BL→TL.
    // Wall index: 0=bottom(BR→BL), 1=right(TR→BR), 2=top(TL→TR), 3=left(BL→TL)
    final walls = [
      (Offset(rect.right, rect.bottom), Offset(rect.left, rect.bottom)), // 0 bottom
      (Offset(rect.right, rect.top), Offset(rect.right, rect.bottom)),   // 1 right
      (Offset(rect.left, rect.top), Offset(rect.right, rect.top)),       // 2 top
      (Offset(rect.left, rect.bottom), Offset(rect.left, rect.top)),     // 3 left
    ];

    for (var i = 0; i < 4; i++) {
      final (from, to) = walls[i];
      if (i != entrance.wall) {
        path.moveTo(from.dx, from.dy);
        path.lineTo(to.dx, to.dy);
        continue;
      }
      // Gap wall
      final dir = to - from;
      final len = dir.distance;
      final unit = dir / len;
      final gapStart = (entrance.pos - entrance.widthFrac / 2).clamp(0.0, 1.0);
      final gapEnd = (entrance.pos + entrance.widthFrac / 2).clamp(0.0, 1.0);
      final pGapStart = from + unit * (gapStart * len);
      final pGapEnd = from + unit * (gapEnd * len);
      if (gapStart > 0) {
        path.moveTo(from.dx, from.dy);
        path.lineTo(pGapStart.dx, pGapStart.dy);
      }
      if (gapEnd < 1) {
        path.moveTo(pGapEnd.dx, pGapEnd.dy);
        path.lineTo(to.dx, to.dy);
      }
    }

    return path;
  }
}
