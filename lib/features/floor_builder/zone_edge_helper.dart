import 'dart:math' as math;
import 'package:flutter/material.dart';

class ZoneEdge {
  const ZoneEdge({
    required this.index,
    required this.startPx,
    required this.endPx,
    required this.midPx,
    required this.angleDeg,
    required this.lengthPx,
    required this.lengthFt,
  });

  final int index;
  final Offset startPx;
  final Offset endPx;
  final Offset midPx;
  final double angleDeg;
  final double lengthPx;
  final double lengthFt;

  static const _padding = 40.0;

  /// Replicates the bounding-box scale transform from [BuilderCanvasPainter]
  /// to produce canvas-pixel edge coordinates from normalized 0..1 zone points.
  static List<ZoneEdge> compute(
    List<Offset> normalizedPts,
    Size canvasSize,
    double pixelsPerFt,
  ) {
    if (normalizedPts.length < 3) return [];

    final minX = normalizedPts.map((p) => p.dx).reduce(math.min);
    final maxX = normalizedPts.map((p) => p.dx).reduce(math.max);
    final minY = normalizedPts.map((p) => p.dy).reduce(math.min);
    final maxY = normalizedPts.map((p) => p.dy).reduce(math.max);

    final rangeX = (maxX - minX).clamp(0.01, 1.0);
    final rangeY = (maxY - minY).clamp(0.01, 1.0);
    final usableW = canvasSize.width - _padding * 2;
    final usableH = canvasSize.height - _padding * 2;
    final scale = (usableW / rangeX).clamp(0.0, usableH / rangeY);
    final scaledW = rangeX * scale;
    final scaledH = rangeY * scale;
    final ox = _padding + (usableW - scaledW) / 2;
    final oy = _padding + (usableH - scaledH) / 2;

    Offset toCanvas(Offset p) =>
        Offset(ox + (p.dx - minX) * scale, oy + (p.dy - minY) * scale);

    final canvasPts = normalizedPts.map(toCanvas).toList();
    final n = canvasPts.length;
    final edges = <ZoneEdge>[];

    for (var i = 0; i < n; i++) {
      final a = canvasPts[i];
      final b = canvasPts[(i + 1) % n];
      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      final lenPx = math.sqrt(dx * dx + dy * dy);
      edges.add(ZoneEdge(
        index: i,
        startPx: a,
        endPx: b,
        midPx: Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2),
        angleDeg: math.atan2(dy, dx) * 180 / math.pi,
        lengthPx: lenPx,
        lengthFt: lenPx / pixelsPerFt,
      ));
    }
    return edges;
  }
}
