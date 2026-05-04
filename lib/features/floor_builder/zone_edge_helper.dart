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
    this.isOnStoreWall = false,
  });

  final int index;
  final Offset startPx;
  final Offset endPx;
  final Offset midPx;
  final double angleDeg;
  final double lengthPx;
  final double lengthFt;
  /// True when both endpoints lie on a store perimeter wall (x≈0, x≈1, y≈0, or y≈1).
  final bool isOnStoreWall;

  static bool _onStoreWall(Offset a, Offset b) {
    const eps = 0.01;
    return (a.dx <= eps && b.dx <= eps) ||
           (a.dx >= 1 - eps && b.dx >= 1 - eps) ||
           (a.dy <= eps && b.dy <= eps) ||
           (a.dy >= 1 - eps && b.dy >= 1 - eps);
  }

  static const _padding = 40.0;

  /// Converts normalized zone points to canvas-pixel edge coordinates.
  ///
  /// When [zoneOriginNorm], [storeWidthFt], [storeDepthFt] are all provided,
  /// uses the feet-based transform that matches [BuilderCanvasPainter]'s
  /// zone background rendering (so edges align with fixtures).
  static List<ZoneEdge> compute(
    List<Offset> normalizedPts,
    Size canvasSize,
    double pixelsPerFt, {
    Offset? zoneOriginNorm,
    double? storeWidthFt,
    double? storeDepthFt,
  }) {
    if (normalizedPts.length < 3) return [];

    final Offset Function(Offset) toCanvas;
    if (storeWidthFt != null && storeDepthFt != null) {
      final minX = normalizedPts.map((p) => p.dx).reduce(math.min);
      final minY = normalizedPts.map((p) => p.dy).reduce(math.min);
      toCanvas = (p) => Offset(
        (p.dx - minX) * storeWidthFt * pixelsPerFt,
        (p.dy - minY) * storeDepthFt * pixelsPerFt,
      );
    } else {
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
      toCanvas = (p) => Offset(ox + (p.dx - minX) * scale, oy + (p.dy - minY) * scale);
    }

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
        isOnStoreWall: storeWidthFt != null
            ? _onStoreWall(normalizedPts[i], normalizedPts[(i + 1) % n])
            : false,
      ));
    }
    return edges;
  }
}
