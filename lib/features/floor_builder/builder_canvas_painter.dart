import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/models/fixture.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'zone_edge_helper.dart';

class BuilderCanvasPainter extends CustomPainter {
  BuilderCanvasPainter({
    required this.fixtures,
    this.selectedFixtureId,
    this.ghostPos,
    this.ghostType,
    this.pixelsPerFt = 20.0,
    this.zoneNormalizedPts,
    this.zoneColor,
    this.zoneName,
    this.wallEdges,
    this.planograms = const {},
  });

  final List<Fixture> fixtures;
  final String? selectedFixtureId;
  final Offset? ghostPos;
  final String? ghostType;
  final double pixelsPerFt;
  final List<Offset>? zoneNormalizedPts;
  final Color? zoneColor;
  final String? zoneName;
  final List<ZoneEdge>? wallEdges;
  final Map<String, PlanogramsTableData> planograms;

  final Map<String, Rect> fixtureRects = {};
  final Map<String, Map<String, Rect>> resizeHandleRects = {};
  final Map<String, Rect> badgeRects = {};
  final Map<String, Rect> badgeBackRects = {};

  @override
  void paint(Canvas canvas, Size size) {
    fixtureRects.clear();
    resizeHandleRects.clear();
    badgeRects.clear();
    badgeBackRects.clear();
    _drawZoneBackground(canvas, size);
    for (final fixture in fixtures) {
      _drawFixture(canvas, fixture);
    }
    if (ghostPos != null && ghostType != null) {
      _drawGhost(canvas, ghostPos!, ghostType!);
    }
    if (wallEdges != null) {
      _drawEdgeHandles(canvas, wallEdges!);
    }
    for (final fixture in fixtures) {
      if (fixture.id == selectedFixtureId) {
        _drawResizeHandles(canvas, fixture);
      }
      _drawPlanogramBadges(canvas, fixture);
    }
  }

  void _drawEdgeHandles(Canvas canvas, List<ZoneEdge> edges) {
    for (var i = 0; i < edges.length; i++) {
      final edge = edges[i];
      canvas.drawLine(
        edge.startPx,
        edge.endPx,
        Paint()
          ..color = AppTheme.accent.withValues(alpha: 0.55)
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(edge.midPx, 14, Paint()..color = AppTheme.accent);
      canvas.drawCircle(
        edge.midPx,
        14,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, edge.midPx - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawZoneBackground(Canvas canvas, Size size) {
    final pts = zoneNormalizedPts;
    if (pts == null || pts.length < 3) return;

    // Find bounding box of normalized points so we can scale to fill the canvas
    double minX = pts.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    double maxX = pts.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
    double minY = pts.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
    double maxY = pts.map((p) => p.dy).reduce((a, b) => a > b ? a : b);

    final rangeX = (maxX - minX).clamp(0.01, 1.0);
    final rangeY = (maxY - minY).clamp(0.01, 1.0);
    const padding = 40.0;
    final usableW = size.width - padding * 2;
    final usableH = size.height - padding * 2;

    // Uniform scale to fit within usable area
    final scale = (usableW / rangeX).clamp(0.0, usableH / rangeY);

    // Center the shape
    final scaledW = rangeX * scale;
    final scaledH = rangeY * scale;
    final offsetX = padding + (usableW - scaledW) / 2;
    final offsetY = padding + (usableH - scaledH) / 2;

    Offset toCanvas(Offset p) => Offset(
          offsetX + (p.dx - minX) / rangeX * scaledW,
          offsetY + (p.dy - minY) / rangeY * scaledH,
        );

    final screenPts = pts.map(toCanvas).toList();
    final path = Path()..addPolygon(screenPts, true);
    final color = zoneColor ?? AppTheme.primary;

    // Floor fill
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.07)..style = PaintingStyle.fill);
    // Zone boundary border
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Zone name label at top of shape
    if (zoneName != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: zoneName!.toUpperCase(),
          style: TextStyle(
            color: color.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final topCenter = screenPts.reduce((a, b) => a.dy < b.dy ? a : b);
      tp.paint(canvas, topCenter.translate(-tp.width / 2, -tp.height - 6));
    }
  }

  void _drawFixture(Canvas canvas, Fixture fixture) {
    final w = fixture.widthFt * pixelsPerFt;
    final d = fixture.depthFt * pixelsPerFt;
    final cx = fixture.posX * pixelsPerFt + w / 2;
    final cy = fixture.posY * pixelsPerFt + d / 2;
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: d);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(fixture.rotation * 3.14159 / 180);
    canvas.translate(-cx, -cy);

    final isSelected = fixture.id == selectedFixtureId;
    final fillColor = isSelected
        ? AppTheme.accent.withValues(alpha: 0.15)
        : AppTheme.primary.withValues(alpha: 0.08);
    final borderColor = isSelected ? AppTheme.accent : AppTheme.primary;

    final fillPaint = Paint()..color = fillColor..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = isSelected ? 2.0 : 1.0
      ..style = PaintingStyle.stroke;

    switch (fixture.fixtureType) {
      case 'rack':
        _drawRack(canvas, rect, fillPaint, borderPaint);
      case 'table':
        _drawTable(canvas, rect, fillPaint, borderPaint);
      case 'shelf':
        _drawShelf(canvas, rect, fillPaint, borderPaint);
      case 'wall':
        _drawWall(canvas, rect, fillPaint, borderPaint);
      case 'partition':
        _drawPartition(canvas, rect, fillPaint, borderPaint);
      default:
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, borderPaint);
    }

    // Label
    final label = fixture.label.isNotEmpty ? fixture.label : fixture.fixtureType.toUpperCase();
    _drawLabel(canvas, label, rect);

    canvas.restore();

    fixtureRects[fixture.id] = rect;
  }

  void _drawRack(Canvas canvas, Rect rect, Paint fill, Paint border) {
    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, border);
    // 3 parallel vertical lines
    final spacing = rect.width / 4;
    final linePaint = Paint()..color = border.color..strokeWidth = 0.8;
    for (int i = 1; i <= 3; i++) {
      final x = rect.left + spacing * i;
      canvas.drawLine(Offset(x, rect.top + 4), Offset(x, rect.bottom - 4), linePaint);
    }
  }

  void _drawTable(Canvas canvas, Rect rect, Paint fill, Paint border) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(AppTheme.borderRadius));
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, border);
  }

  void _drawShelf(Canvas canvas, Rect rect, Paint fill, Paint border) {
    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, border);
    // 3 horizontal lines
    final spacing = rect.height / 4;
    final linePaint = Paint()..color = border.color..strokeWidth = 0.8;
    for (int i = 1; i <= 3; i++) {
      final y = rect.top + spacing * i;
      canvas.drawLine(Offset(rect.left + 4, y), Offset(rect.right - 4, y), linePaint);
    }
  }

  void _drawWall(Canvas canvas, Rect rect, Paint fill, Paint border) {
    final wallPaint = Paint()..color = AppTheme.primary.withValues(alpha: 0.35)..style = PaintingStyle.fill;
    canvas.drawRect(rect, wallPaint);
    canvas.drawRect(rect, border);
  }

  void _drawPartition(Canvas canvas, Rect rect, Paint fill, Paint border) {
    // Interior divider — dashed centre line with light fill
    canvas.drawRect(rect, Paint()..color = AppTheme.accent.withValues(alpha: 0.12)..style = PaintingStyle.fill);
    canvas.drawRect(rect, Paint()..color = AppTheme.accent..strokeWidth = 1.5..style = PaintingStyle.stroke);
    // Dashed centre line along long axis
    final isWide = rect.width >= rect.height;
    final dashPaint = Paint()..color = AppTheme.accent..strokeWidth = 1.0;
    const dashLen = 4.0;
    const gap = 3.0;
    if (isWide) {
      double x = rect.left + 4;
      final y = rect.center.dy;
      while (x < rect.right - 4) {
        canvas.drawLine(Offset(x, y), Offset((x + dashLen).clamp(rect.left, rect.right - 4), y), dashPaint);
        x += dashLen + gap;
      }
    } else {
      double y = rect.top + 4;
      final x = rect.center.dx;
      while (y < rect.bottom - 4) {
        canvas.drawLine(Offset(x, y), Offset(x, (y + dashLen).clamp(rect.top, rect.bottom - 4)), dashPaint);
        y += dashLen + gap;
      }
    }
  }

  void _drawGhost(Canvas canvas, Offset pos, String type) {
    final w = 4.0 * pixelsPerFt;
    final d = 2.0 * pixelsPerFt;
    final rect = Rect.fromCenter(center: pos, width: w, height: d);
    final ghostPaint = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, ghostPaint);
  }

  void _drawLabel(Canvas canvas, String text, Rect rect) {
    final span = TextSpan(
      text: text.toUpperCase(),
      style: const TextStyle(
        fontSize: DesignTokens.typeXs,
        fontWeight: DesignTokens.weightBold,
        color: AppTheme.textPrimary,
      ),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
      ..layout(maxWidth: rect.width - 4);
    tp.paint(
      canvas,
      Offset(rect.left + (rect.width - tp.width) / 2, rect.top + (rect.height - tp.height) / 2),
    );
  }

  void _drawResizeHandles(Canvas canvas, Fixture fixture) {
    final rect = fixtureRects[fixture.id];
    if (rect == null) return;
    final handles = _handlesForType(fixture.fixtureType);
    final handleRects = <String, Rect>{};
    const handleSize = 18.0;
    for (final h in handles) {
      Offset center;
      switch (h) {
        case 'top':
          center = Offset(rect.center.dx, rect.top);
        case 'bottom':
          center = Offset(rect.center.dx, rect.bottom);
        case 'left':
          center = Offset(rect.left, rect.center.dy);
        case 'right':
          center = Offset(rect.right, rect.center.dy);
        default:
          continue;
      }
      final hr = Rect.fromCenter(center: center, width: handleSize, height: handleSize);
      handleRects[h] = hr;
      canvas.drawRRect(
        RRect.fromRectAndRadius(hr, const Radius.circular(4)),
        Paint()..color = const Color(0xFFBF5534)..style = PaintingStyle.fill,
      );
      _drawArrow(canvas, center, h == 'left' || h == 'right');
    }
    resizeHandleRects[fixture.id] = handleRects;
  }

  List<String> _handlesForType(String fixtureType) {
    switch (fixtureType) {
      case 'wall':
      case 'shelf':
        return ['left', 'right'];
      case 'rack':
      case 'table':
      case 'partition':
      default:
        return ['top', 'bottom', 'left', 'right'];
    }
  }

  void _drawArrow(Canvas canvas, Offset center, bool horizontal) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const arm = 4.0;
    if (horizontal) {
      canvas.drawLine(center.translate(-arm, 0), center.translate(arm, 0), paint);
      canvas.drawLine(center.translate(-arm, 0), center.translate(-arm + 2, -2), paint);
      canvas.drawLine(center.translate(-arm, 0), center.translate(-arm + 2, 2), paint);
      canvas.drawLine(center.translate(arm, 0), center.translate(arm - 2, -2), paint);
      canvas.drawLine(center.translate(arm, 0), center.translate(arm - 2, 2), paint);
    } else {
      canvas.drawLine(center.translate(0, -arm), center.translate(0, arm), paint);
      canvas.drawLine(center.translate(0, -arm), center.translate(-2, -arm + 2), paint);
      canvas.drawLine(center.translate(0, -arm), center.translate(2, -arm + 2), paint);
      canvas.drawLine(center.translate(0, arm), center.translate(-2, arm - 2), paint);
      canvas.drawLine(center.translate(0, arm), center.translate(2, arm - 2), paint);
    }
  }

  void _drawPlanogramBadges(Canvas canvas, Fixture fixture) {
    final rect = fixtureRects[fixture.id];
    if (rect == null) return;
    if (fixture.fixtureType == 'partition') {
      _drawPartitionBadges(canvas, fixture, rect);
    } else {
      final badgeRect = _badgeRect(Offset(rect.right - 2, rect.bottom - 2), anchor: 'bottomRight');
      badgeRects[fixture.id] = badgeRect;
      _paintBadge(canvas, badgeRect, fixture.planogramId, planograms[fixture.planogramId]?.title);
    }
  }

  void _drawPartitionBadges(Canvas canvas, Fixture fixture, Rect rect) {
    final isWide = rect.width >= rect.height;
    if (isWide) {
      final frontRect = _badgeRect(Offset(rect.center.dx, rect.bottom - 2), anchor: 'bottomCenter');
      badgeRects[fixture.id] = frontRect;
      _paintBadge(canvas, frontRect, fixture.planogramId, planograms[fixture.planogramId]?.title);
      if (!fixture.wallAdjacent) {
        final backRect = _badgeRect(Offset(rect.center.dx, rect.top + 2), anchor: 'topCenter');
        badgeBackRects[fixture.id] = backRect;
        _paintBadge(canvas, backRect, fixture.planogramIdBack, planograms[fixture.planogramIdBack]?.title);
      }
    } else {
      final frontRect = _badgeRect(Offset(rect.right - 2, rect.center.dy), anchor: 'rightCenter');
      badgeRects[fixture.id] = frontRect;
      _paintBadge(canvas, frontRect, fixture.planogramId, planograms[fixture.planogramId]?.title);
      if (!fixture.wallAdjacent) {
        final backRect = _badgeRect(Offset(rect.left + 2, rect.center.dy), anchor: 'leftCenter');
        badgeBackRects[fixture.id] = backRect;
        _paintBadge(canvas, backRect, fixture.planogramIdBack, planograms[fixture.planogramIdBack]?.title);
      }
    }
  }

  Rect _badgeRect(Offset anchorPt, {required String anchor}) {
    const w = 44.0;
    const h = 18.0;
    switch (anchor) {
      case 'bottomRight':
        return Rect.fromLTWH(anchorPt.dx - w, anchorPt.dy - h, w, h);
      case 'bottomCenter':
        return Rect.fromCenter(center: Offset(anchorPt.dx, anchorPt.dy - h / 2), width: w, height: h);
      case 'topCenter':
        return Rect.fromCenter(center: Offset(anchorPt.dx, anchorPt.dy + h / 2), width: w, height: h);
      case 'rightCenter':
        return Rect.fromLTWH(anchorPt.dx - w, anchorPt.dy - h / 2, w, h);
      case 'leftCenter':
        return Rect.fromLTWH(anchorPt.dx, anchorPt.dy - h / 2, w, h);
      default:
        return Rect.fromCenter(center: anchorPt, width: w, height: h);
    }
  }

  void _paintBadge(Canvas canvas, Rect rect, String? planogramId, String? title) {
    final isAssigned = planogramId != null;
    final bgColor = isAssigned ? const Color(0xFFBF5534) : Colors.grey.shade400;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = bgColor,
    );
    final label = isAssigned
        ? (title != null && title.length > 14 ? '${title.substring(0, 13)}\u2026' : (title ?? '\u2014'))
        : '\u2014';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 4);
    tp.paint(canvas, Offset(rect.left + (rect.width - tp.width) / 2, rect.top + (rect.height - tp.height) / 2));
  }

  @override
  bool shouldRepaint(BuilderCanvasPainter old) =>
      old.fixtures != fixtures ||
      old.selectedFixtureId != selectedFixtureId ||
      old.ghostPos != ghostPos ||
      old.wallEdges != wallEdges ||
      old.planograms != planograms;
}
