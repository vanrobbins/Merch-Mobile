import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/models/store_zone.dart';
import '../../core/theme/app_theme.dart';
import 'store_entrance.dart';
import 'zone_shape.dart';

class ZoneMapPainter extends CustomPainter {
  ZoneMapPainter({
    required this.zones,
    required this.canvasSize,
    this.selectedZoneId,
    this.widthFt,
    this.depthFt,
    this.entranceJson,
    this.storeShapePoints,
    this.activeVertexIdx,
    this.snapPreviewPoints,
    this.entranceEditMode = false,
    this.storeShapeEditMode = false,
    this.activeStoreVertexIdx,
    this.liveEntrance,
    this.overlappingZoneIds = const {},
  });

  final List<StoreZone> zones;
  final Size canvasSize;
  final String? selectedZoneId;
  final double? widthFt;
  final double? depthFt;
  final String? entranceJson;
  final List<Offset>? storeShapePoints;
  final int? activeVertexIdx;
  final List<Offset>? snapPreviewPoints;
  final bool entranceEditMode;
  final bool storeShapeEditMode;
  final int? activeStoreVertexIdx;
  final StoreEntrance? liveEntrance;
  final Set<String> overlappingZoneIds;

  final Map<String, Path> _zonePaths = {};

  bool get _hasStoreDims => widthFt != null && depthFt != null;

  double get _pixelsPerFt {
    if (!_hasStoreDims) return 0;
    return (canvasSize.width / widthFt!).clamp(0, canvasSize.height / depthFt!);
  }

  Rect get _storeRect {
    final ppf = _pixelsPerFt;
    if (ppf == 0) return Rect.zero;
    return Rect.fromLTWH(0, 0, widthFt! * ppf, depthFt! * ppf);
  }

  List<Offset>? get _storePolyCanvasPts {
    if (storeShapePoints == null || storeShapePoints!.length < 3) return null;
    final ppf = _pixelsPerFt;
    if (ppf == 0) return null;
    final storeW = widthFt! * ppf;
    final storeH = depthFt! * ppf;
    return storeShapePoints!
        .map((p) => Offset(p.dx * storeW, p.dy * storeH))
        .toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _zonePaths.clear();
    _drawGrid(canvas, size);
    if (_hasStoreDims) _drawStoreBoundary(canvas);
    if (entranceEditMode && _hasStoreDims) {
      if (liveEntrance != null) {
        _drawEntranceHandles(canvas, liveEntrance!);
      } else {
        _drawEntrancePlacementHints(canvas);
      }
    }

    for (final zone in zones) {
      _drawZone(canvas, size, zone);
    }

    final selected = selectedZoneId == null
        ? null
        : zones.where((z) => z.id == selectedZoneId).firstOrNull;
    if (selected != null) _drawVertexHandles(canvas, size, selected);
    if (snapPreviewPoints != null) _drawSnapPreview(canvas, size, snapPreviewPoints!);
    if (storeShapeEditMode && storeShapePoints != null) _drawStoreVertexHandles(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final ppf = _pixelsPerFt;
    final useFtGrid = ppf > 0 && _hasStoreDims;

    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: useFtGrid ? 0.15 : 0.10)
      ..strokeWidth = 0.5;

    if (useFtGrid) {
      const ftStep = 5.0;
      final stepPx = ftStep * ppf;
      final boundary = _storeRect;
      for (double x = 0; x <= boundary.width + 0.1; x += stepPx) {
        canvas.drawLine(Offset(x, 0), Offset(x, boundary.height), paint);
      }
      for (double y = 0; y <= boundary.height + 0.1; y += stepPx) {
        canvas.drawLine(Offset(0, y), Offset(boundary.width, y), paint);
      }
    } else {
      const step = 40.0;
      for (double x = 0; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
      for (double y = 0; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }
  }

  void _drawStoreBoundary(Canvas canvas) {
    final rect = _storeRect;
    final borderPaint = Paint()
      ..color = const Color(0xFF1A1917)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.square;
    final entrance = liveEntrance ?? StoreEntrance.fromJson(entranceJson);

    final polyPts = _storePolyCanvasPts;
    if (polyPts != null) {
      final fillPath = Path()..addPolygon(polyPts, true);
      canvas.drawPath(fillPath, Paint()..color = const Color(0xFFF2EFE8));
      final borderPath = StoreEntrance.boundaryPathPolygon(polyPts, entrance);
      canvas.drawPath(borderPath, borderPaint);
    } else {
      canvas.drawRect(rect, Paint()..color = const Color(0xFFF2EFE8));
      final borderPath = StoreEntrance.boundaryPath(rect, entrance);
      canvas.drawPath(borderPath, borderPaint);
    }
  }

  void _drawStoreVertexHandles(Canvas canvas) {
    if (storeShapePoints == null || storeShapePoints!.isEmpty) return;
    final ppf = _pixelsPerFt;
    if (ppf == 0) return;
    final storeW = widthFt! * ppf;
    final storeH = depthFt! * ppf;
    final pts = storeShapePoints!
        .map((p) => Offset(p.dx * storeW, p.dy * storeH))
        .toList();

    final ringPaint = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final fillPaint = Paint()..color = Colors.white;
    final activeFill = Paint()..color = AppTheme.accent;

    for (var i = 0; i < pts.length; i++) {
      const r = 8.0;
      canvas.drawCircle(pts[i], r, i == activeStoreVertexIdx ? activeFill : fillPaint);
      canvas.drawCircle(pts[i], r, ringPaint);
    }
  }

  void _drawZone(Canvas canvas, Size size, StoreZone zone) {
    final points = _getPoints(zone, size);
    if (points.length < 3) return;

    final path = Path()..addPolygon(points, true);
    _zonePaths[zone.id] = path;

    final color = Color(zone.colorValue);
    final isSelected = zone.id == selectedZoneId;
    final isDisplay = zone.zoneType == 'display';

    final centroid = _centroid(points);
    final outsideBoundary = _hasStoreDims && !_storeRect.contains(centroid);

    final fillColor = outsideBoundary
        ? Colors.red.withValues(alpha: 0.18)
        : color.withValues(alpha: isSelected ? 0.45 : 0.20);
    canvas.drawPath(path, Paint()..color = fillColor);

    if (isSelected) {
      _drawDashedPath(
        canvas,
        path,
        Paint()
          ..color = AppTheme.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round,
      );
    } else {
      final strokePaint = Paint()
        ..color = outsideBoundary
            ? Colors.red.withValues(alpha: 0.6)
            : color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round;
      if (isDisplay) {
        canvas.drawPath(path, strokePaint);
      } else {
        _drawDashedPath(canvas, path, strokePaint);
      }
    }

    if (overlappingZoneIds.contains(zone.id)) {
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.red.withValues(alpha: 0.20)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.red.withValues(alpha: 0.60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    final tp = TextPainter(
      text: TextSpan(
        text: zone.name.toUpperCase(),
        style: TextStyle(
          color: color.withValues(alpha: 0.95),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          shadows: [
            Shadow(
              color: Colors.white.withValues(alpha: 0.7),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, centroid - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawVertexHandles(Canvas canvas, Size size, StoreZone zone) {
    final points = _getPoints(zone, size);

    if (activeVertexIdx != null && _hasStoreDims) {
      final normPts = ZoneShape.decode(zone.shapePoints);
      final n = normPts.length;
      for (var i = 0; i < n; i++) {
        // only draw edges adjacent to the active vertex
        final next = (i + 1) % n;
        if (i != activeVertexIdx && next != activeVertexIdx) continue;

        final dxFt = (normPts[next].dx - normPts[i].dx) * widthFt!;
        final dyFt = (normPts[next].dy - normPts[i].dy) * depthFt!;
        final lengthFt = sqrt(dxFt * dxFt + dyFt * dyFt);
        final label = '${lengthFt.toStringAsFixed(1)} ft';

        final mid = (points[i] + points[next]) / 2;
        _drawEdgeLabel(canvas, label, mid);
      }
    }

    final fillPaint = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final p in points) {
      canvas.drawCircle(p, 8.0, fillPaint);
      canvas.drawCircle(p, 8.0, strokePaint);
    }
  }

  void _drawSnapPreview(Canvas canvas, Size size, List<Offset> normPts) {
    final cPts = normPts.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();
    final path = Path()..addPolygon(cPts, true);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.accent.withValues(alpha: 40/255)
        ..style = PaintingStyle.fill,
    );
    _drawDashedPath(
      canvas,
      path,
      Paint()
        ..color = AppTheme.accent.withValues(alpha: 180/255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawEdgeLabel(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF1A1917),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    const hPad = 6.0;
    const vPad = 3.0;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: tp.width + hPad * 2,
        height: tp.height + vPad * 2,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(bgRect, Paint()..color = const Color(0xFFF2EFE8));
    canvas.drawRRect(
      bgRect,
      Paint()
        ..color = AppTheme.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  List<Offset> _getPoints(StoreZone zone, Size size) {
    final decoded = ZoneShape.decode(zone.shapePoints);
    if (decoded.isNotEmpty) {
      return [
        for (final p in decoded) Offset(p.dx * size.width, p.dy * size.height),
      ];
    }
    final x = zone.posX * size.width;
    final y = zone.posY * size.height;
    final w = zone.width * size.width;
    final h = zone.height * size.height;
    return [Offset(x, y), Offset(x + w, y), Offset(x + w, y + h), Offset(x, y + h)];
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLen = 8.0;
    const gapLen = 5.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final end = (dist + dashLen).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  Offset _centroid(List<Offset> pts) {
    final sum = pts.fold<Offset>(Offset.zero, (acc, p) => acc + p);
    return sum / pts.length.toDouble();
  }

  String? zoneIdAt(Offset position, {double centroidHitRadius = 0}) {
    for (final zone in zones.reversed) {
      final path = _zonePaths[zone.id];
      if (path != null && path.contains(position)) return zone.id;
    }
    // fallback: centroid hit for zones whose polygon is mostly off-canvas
    if (centroidHitRadius > 0) {
      for (final zone in zones.reversed) {
        final pts = _getPoints(zone, canvasSize);
        if (pts.isEmpty) continue;
        if ((_centroid(pts) - position).distance < centroidHitRadius) return zone.id;
      }
    }
    return null;
  }

  int vertexIndexAt(String zoneId, Offset position, Size size,
      {double hitRadius = 20.0}) {
    final zone = zones.where((z) => z.id == zoneId).firstOrNull;
    if (zone == null) return -1;
    final pts = _getPoints(zone, size);
    for (var i = 0; i < pts.length; i++) {
      if ((pts[i] - position).distance < hitRadius) return i;
    }
    return -1;
  }

  List<(Offset, Offset)> _wallSegments(Rect rect) => [
    (Offset(rect.right, rect.bottom), Offset(rect.left, rect.bottom)),
    (Offset(rect.right, rect.top), Offset(rect.right, rect.bottom)),
    (Offset(rect.left, rect.top), Offset(rect.right, rect.top)),
    (Offset(rect.left, rect.bottom), Offset(rect.left, rect.top)),
  ];

  void _drawEntranceHandles(Canvas canvas, StoreEntrance e) {
    Offset from, to;
    final polyPts = _storePolyCanvasPts;
    if (polyPts != null) {
      final edgeIdx = StoreEntrance.edgeForWall(storeShapePoints!, e.wall);
      from = polyPts[edgeIdx];
      to = polyPts[(edgeIdx + 1) % polyPts.length];
    } else {
      final walls = _wallSegments(_storeRect);
      (from, to) = walls[e.wall.clamp(0, 3)];
    }
    final dir = to - from;
    final gapStart = (e.pos - e.widthFrac / 2).clamp(0.0, 1.0);
    final gapEnd = (e.pos + e.widthFrac / 2).clamp(0.0, 1.0);
    final pCenter = from + dir * e.pos;
    final pEnd1 = from + dir * gapStart;
    final pEnd2 = from + dir * gapEnd;

    canvas.drawLine(
      pEnd1,
      pEnd2,
      Paint()
        ..color = AppTheme.accent
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );
    _drawHandle(canvas, pCenter, radius: 8.0);
    _drawHandle(canvas, pEnd1, radius: 6.0);
    _drawHandle(canvas, pEnd2, radius: 6.0);
  }

  void _drawHandle(Canvas canvas, Offset center, {required double radius}) {
    canvas.drawCircle(center, radius + 1.5, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius, Paint()..color = AppTheme.accent);
  }

  void _drawEntrancePlacementHints(Canvas canvas) {
    final hintPaint = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.35)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final polyPts = _storePolyCanvasPts;
    if (polyPts != null) {
      final n = polyPts.length;
      for (int i = 0; i < n; i++) {
        final from = polyPts[i];
        final to = polyPts[(i + 1) % n];
        final mid = (from + to) / 2;
        final dir = to - from;
        final len = dir.distance;
        if (len < 1) continue;
        // outward normal for clockwise polygon (Y down)
        final norm = Offset(dir.dy / len, -dir.dx / len);
        canvas.drawLine(mid, mid + norm * 10, hintPaint);
        _drawPlacementLabel(canvas, 'TAP TO PLACE', mid + norm * 22);
      }
      return;
    }

    final rect = _storeRect;
    final wallMids = [
      Offset(rect.center.dx, rect.bottom),
      Offset(rect.right, rect.center.dy),
      Offset(rect.center.dx, rect.top),
      Offset(rect.left, rect.center.dy),
    ];
    const wallNormals = [
      Offset(0, 1),
      Offset(1, 0),
      Offset(0, -1),
      Offset(-1, 0),
    ];
    for (var i = 0; i < 4; i++) {
      final mid = wallMids[i];
      final norm = wallNormals[i];
      canvas.drawLine(mid, mid + norm * 10, hintPaint);
      _drawPlacementLabel(canvas, 'TAP TO PLACE', mid + norm * 22);
    }
  }

  void _drawPlacementLabel(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: AppTheme.accent.withValues(alpha: 0.55),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(ZoneMapPainter old) =>
      old.zones != zones ||
      old.selectedZoneId != selectedZoneId ||
      old.widthFt != widthFt ||
      old.depthFt != depthFt ||
      old.entranceJson != entranceJson ||
      old.activeVertexIdx != activeVertexIdx ||
      old.snapPreviewPoints != snapPreviewPoints ||
      old.entranceEditMode != entranceEditMode ||
      old.liveEntrance != liveEntrance ||
      old.overlappingZoneIds != overlappingZoneIds;
}
