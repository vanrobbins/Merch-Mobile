import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import 'zone_shape.dart';

class ZoneMapPainter extends CustomPainter {
  ZoneMapPainter({
    required this.zones,
    required this.canvasSize,
    this.selectedZoneId,
    this.onZoneTap,
  });

  final List<ZonesTableData> zones;
  final Size canvasSize;
  final String? selectedZoneId;
  final void Function(String zoneId)? onZoneTap;

  // Cache hit-test paths for tap detection
  final Map<String, Path> _zonePaths = {};

  @override
  void paint(Canvas canvas, Size size) {
    _zonePaths.clear();
    _drawGrid(canvas, size);
    for (final zone in zones) {
      _drawZone(canvas, size, zone);
    }
    // Draw vertex handles on selected zone
    if (selectedZoneId != null) {
      final selected = zones.where((z) => z.id == selectedZoneId).firstOrNull;
      if (selected != null) {
        _drawVertexHandles(canvas, size, selected);
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawZone(Canvas canvas, Size size, ZonesTableData zone) {
    final points = _getPoints(zone, size);
    if (points.length < 3) return;

    final path = Path()..addPolygon(points, true);
    _zonePaths[zone.id] = path;

    final color = Color(zone.colorValue);
    final isSelected = zone.id == selectedZoneId;
    final isDisplay = zone.zoneType == 'display';

    // Fill
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(isSelected ? 0.35 : 0.22)
        ..style = PaintingStyle.fill,
    );

    // Stroke — dashed for non-display zones
    final strokePaint = Paint()
      ..color = isSelected ? color : color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.5;

    if (!isDisplay) {
      _drawDashedPath(canvas, path, strokePaint);
    } else {
      canvas.drawPath(path, strokePaint);
    }

    // Zone name label — white halo improves contrast over the fill.
    final centroid = _centroid(points);
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
              offset: const Offset(0, 0),
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
    final color = Color(zone.colorValue);
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final p in points) {
      canvas.drawCircle(p, 8.0, fillPaint);
      canvas.drawCircle(p, 8.0, strokePaint);
    }
  }

  List<Offset> _getPoints(ZonesTableData zone, Size size) {
    final decoded = ZoneShape.decode(zone.shapePoints);
    if (decoded.isNotEmpty) {
      // shapePoints stores normalized 0..1 coords — scale to canvas
      return decoded
          .map((p) => Offset(p.dx * size.width, p.dy * size.height))
          .toList();
    }
    // Fallback to posX/posY/width/height (legacy)
    final x = zone.posX * size.width;
    final y = zone.posY * size.height;
    final w = zone.width * size.width;
    final h = zone.height * size.height;
    return [
      Offset(x, y),
      Offset(x + w, y),
      Offset(x + w, y + h),
      Offset(x, y + h),
    ];
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLen = 8.0;
    const gapLen = 5.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        final end = (dist + dashLen).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  Offset _centroid(List<Offset> pts) {
    var x = 0.0, y = 0.0;
    for (final p in pts) {
      x += p.dx;
      y += p.dy;
    }
    return Offset(x / pts.length, y / pts.length);
  }

  /// Returns the zone ID at [position], or null. Not an override of CustomPainter.hitTest.
  String? zoneIdAt(Offset position) {
    // Iterate in reverse so topmost zone is hit first
    for (final zone in zones.reversed) {
      final path = _zonePaths[zone.id];
      if (path != null && path.contains(position)) return zone.id;
    }
    return null;
  }

  @override
  bool shouldRepaint(ZoneMapPainter old) =>
      old.zones != zones || old.selectedZoneId != selectedZoneId;
}
