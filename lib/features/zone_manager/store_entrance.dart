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

  /// Find the polygon edge index whose midpoint best matches the given wall direction.
  /// wall: 0=bottom (max Y), 1=right (max X), 2=top (min Y), 3=left (min X).
  /// Works with any coordinate system (normalized or canvas pixels).
  static int edgeForWall(List<Offset> pts, int wall) {
    final n = pts.length;
    if (n < 2) return 0;
    int best = 0;
    double bestScore = double.negativeInfinity;
    for (int i = 0; i < n; i++) {
      final mid = (pts[i] + pts[(i + 1) % n]) / 2;
      final score = wall == 0
          ? mid.dy
          : wall == 1
              ? mid.dx
              : wall == 2
                  ? -mid.dy
                  : -mid.dx;
      if (score > bestScore) {
        bestScore = score;
        best = i;
      }
    }
    return best;
  }

  /// Build a boundary [Path] for a polygon (canvas coords) with an entrance gap.
  /// The gap is cut on the edge whose midpoint is closest to [entrance.wall] direction.
  static Path boundaryPathPolygon(List<Offset> canvasPts, StoreEntrance? entrance) {
    final n = canvasPts.length;
    if (n < 3) return Path()..addPolygon(canvasPts, true);
    if (entrance == null) return Path()..addPolygon(canvasPts, true);

    final edgeIdx = edgeForWall(canvasPts, entrance.wall);
    final from = canvasPts[edgeIdx];
    final to = canvasPts[(edgeIdx + 1) % n];
    final dir = to - from;
    final len = dir.distance;
    if (len < 1.0) return Path()..addPolygon(canvasPts, true);
    final unit = dir / len;

    final gapStartFrac = (entrance.pos - entrance.widthFrac / 2).clamp(0.0, 1.0);
    final gapEndFrac = (entrance.pos + entrance.widthFrac / 2).clamp(0.0, 1.0);
    final pGapStart = from + unit * (gapStartFrac * len);
    final pGapEnd = from + unit * (gapEndFrac * len);

    // Start at gapEnd, finish the entrance edge, traverse all other edges, end at gapStart.
    final path = Path();
    path.moveTo(pGapEnd.dx, pGapEnd.dy);
    path.lineTo(to.dx, to.dy);
    for (int i = 1; i < n - 1; i++) {
      final idx = (edgeIdx + 1 + i) % n;
      path.lineTo(canvasPts[idx].dx, canvasPts[idx].dy);
    }
    path.lineTo(from.dx, from.dy);
    if (gapStartFrac > 0) path.lineTo(pGapStart.dx, pGapStart.dy);
    return path;
  }

  /// Builds a boundary [Path] for [rect] with this entrance cut out.
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
