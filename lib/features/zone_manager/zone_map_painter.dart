import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import 'zone_shape.dart';

class ZoneMapPainter extends CustomPainter {
  ZoneMapPainter({
    required this.zones,
    required this.canvasSize,
    this.selectedZoneId,
    this.widthFt,
    this.depthFt,
    this.activeVertexIdx,
  });

  final List<ZonesTableData> zones;
  final Size canvasSize;
  final String? selectedZoneId;
  final double? widthFt;
  final double? depthFt;
  final int? activeVertexIdx;

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

  @override
  void paint(Canvas canvas, Size size) {
    _zonePaths.clear();
    _drawGrid(canvas, size);
    if (_hasStoreDims) _drawStoreBoundary(canvas);

    for (final zone in zones) {
      _drawZone(canvas, size, zone);
    }

    final selected = selectedZoneId == null
        ? null
        : zones.where((z) => z.id == selectedZoneId).firstOrNull;
    if (selected != null) _drawVertexHandles(canvas, size, selected);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final ppf = _pixelsPerFt;
    final useFtGrid = ppf > 0 && _hasStoreDims;

    final paint = Paint()
      ..color = Colors.grey.withOpacity(useFtGrid ? 0.15 : 0.10)
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
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      Paint()..color = Colors.black.withOpacity(0.04),
    );
    canvas.drawRect(rect, Paint()..color = const Color(0xFFF2EFE8));
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFF1A1917)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _drawZone(Canvas canvas, Size size, ZonesTableData zone) {
    final points = _getPoints(zone, size);
    if (points.length < 3) return;

    final path = Path()..addPolygon(points, true);
    _zonePaths[zone.id] = path;

    final color = Color(zone.colorValue);
    final isSelected = zone.id == selectedZoneId;
    final isDisplay = zone.zoneType == 'display';

    final centroid = _centroid(points);
    final outsideBoundary = _hasStoreDims && !_storeRect.contains(centroid);

    // Fill
    final fillColor = outsideBoundary
        ? Colors.red.withOpacity(0.18)
        : color.withOpacity(isSelected ? 0.45 : 0.20);
    canvas.drawPath(path, Paint()..color = fillColor);

    // Stroke
    if (isSelected) {
      _drawDashedPath(
        canvas,
        path,
        Paint()
          ..color = const Color(0xFFBF5534)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round,
      );
    } else {
      final strokePaint = Paint()
        ..color = outsideBoundary
            ? Colors.red.withOpacity(0.6)
            : color.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round;
      if (isDisplay) {
        canvas.drawPath(path, strokePaint);
      } else {
        _drawDashedPath(canvas, path, strokePaint);
      }
    }

    // Label
    final tp = TextPainter(
      text: TextSpan(
        text: zone.name.toUpperCase(),
        style: TextStyle(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.95),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          shadows: [
            Shadow(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.7),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, centroid - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawVertexHandles(Canvas canvas, Size size, ZonesTableData zone) {
    final points = _getPoints(zone, size);

    // Draw edge length labels when a vertex is actively dragged.
    if (activeVertexIdx != null && _hasStoreDims) {
      final normPts = ZoneShape.decode(zone.shapePoints);
      final n = normPts.length;
      for (var i = 0; i < n; i++) {
        // Only draw edges that involve the active vertex.
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
      ..color = const Color(0xFFBF5534)
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
        ..color = const Color(0xFFBF5534)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  List<Offset> _getPoints(ZonesTableData zone, Size size) {
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

  String? zoneIdAt(Offset position) {
    for (final zone in zones.reversed) {
      final path = _zonePaths[zone.id];
      if (path != null && path.contains(position)) return zone.id;
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

  @override
  bool shouldRepaint(ZoneMapPainter old) =>
      old.zones != zones ||
      old.selectedZoneId != selectedZoneId ||
      old.widthFt != widthFt ||
      old.depthFt != depthFt ||
      old.activeVertexIdx != activeVertexIdx;
}
