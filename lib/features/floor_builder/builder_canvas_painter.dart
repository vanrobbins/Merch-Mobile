import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/models/fixture.dart';
import '../../core/models/mannequin.dart';
import '../../core/models/platform_element.dart';
import '../../core/models/planogram.dart';
import '../../core/models/scene_prop.dart';
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
    this.viewScale = 1.0,
    this.zoneNormalizedPts,
    this.zoneOriginNorm,
    this.storeWidthFt,
    this.storeDepthFt,
    this.zoneColor,
    this.zoneName,
    this.wallEdges,
    this.planograms = const {},
    this.mannequins = const [],
    this.platforms = const [],
    this.sceneProps = const [],
    this.selectedFixtureIds = const {},
  });

  final List<Fixture> fixtures;
  final String? selectedFixtureId;
  final Offset? ghostPos;
  final String? ghostType;
  final double pixelsPerFt;
  final double viewScale;
  final List<Offset>? zoneNormalizedPts;
  /// Zone top-left in store-normalized (0–1) space — (zone.posX, zone.posY).
  final Offset? zoneOriginNorm;
  final double? storeWidthFt;
  final double? storeDepthFt;
  final Color? zoneColor;
  final String? zoneName;
  final List<ZoneEdge>? wallEdges;
  final Map<String, Planogram> planograms;
  final List<Mannequin> mannequins;
  final List<PlatformElement> platforms;
  final List<SceneProp> sceneProps;
  final Set<String> selectedFixtureIds;

  Map<String, Rect> fixtureRects = {};
  Map<String, Map<String, Rect>> resizeHandleRects = {};
  Map<String, Rect> badgeRects = {};
  Map<String, Rect> badgeBackRects = {};
  Map<String, Rect> propRects = {};
  Map<String, Rect> mannequinRects = {};
  Map<String, Rect> platformRects = {};
  Map<String, double> fixtureAngles = {};

  @override
  void paint(Canvas canvas, Size size) {
    fixtureRects = {};
    resizeHandleRects = {};
    badgeRects = {};
    badgeBackRects = {};
    propRects = {};
    mannequinRects = {};
    platformRects = {};
    fixtureAngles = {};
    _drawZoneBackground(canvas, size);
    for (final platform in platforms) {
      _drawPlatform(canvas, platform);
    }
    for (final fixture in fixtures) {
      _drawFixture(canvas, fixture);
    }
    for (final prop in sceneProps) {
      _drawSceneProp(canvas, prop);
    }
    for (final mannequin in mannequins) {
      _drawMannequin(canvas, mannequin);
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

    final List<Offset> screenPts;

    if (storeWidthFt != null && storeDepthFt != null) {
      // Derive origin from actual shape-point extents — zone.posX/posY is not kept in sync.
      final minX = pts.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
      final minY = pts.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
      screenPts = pts.map((p) => Offset(
        (p.dx - minX) * storeWidthFt! * pixelsPerFt,
        (p.dy - minY) * storeDepthFt! * pixelsPerFt,
      )).toList();
    } else {
      // Fallback: scale to fill canvas (disconnected from fixture space)
      double minX = pts.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
      double maxX = pts.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
      double minY = pts.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
      double maxY = pts.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
      final rangeX = (maxX - minX).clamp(0.01, 1.0);
      final rangeY = (maxY - minY).clamp(0.01, 1.0);
      const padding = 40.0;
      final usableW = size.width - padding * 2;
      final usableH = size.height - padding * 2;
      final scale = (usableW / rangeX).clamp(0.0, usableH / rangeY);
      final scaledW = rangeX * scale;
      final scaledH = rangeY * scale;
      final offsetX = padding + (usableW - scaledW) / 2;
      final offsetY = padding + (usableH - scaledH) / 2;
      screenPts = pts.map((p) => Offset(
        offsetX + (p.dx - minX) / rangeX * scaledW,
        offsetY + (p.dy - minY) / rangeY * scaledH,
      )).toList();
    }
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

    final isMultiSelected = selectedFixtureIds.contains(fixture.id);
    if (isMultiSelected && !isSelected) {
      const dashLen = 5.0;
      const gap = 3.0;
      final dashPaint = Paint()
        ..color = AppTheme.accent
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      _drawDashedRect(canvas, rect, dashPaint, dashLen, gap);
    }

    fixtureRects[fixture.id] = rect;
    fixtureAngles[fixture.id] = fixture.rotation;
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint, double dashLen, double gap) {
    // Top edge
    double x = rect.left;
    while (x < rect.right) {
      canvas.drawLine(
        Offset(x, rect.top),
        Offset((x + dashLen).clamp(rect.left, rect.right), rect.top),
        paint,
      );
      x += dashLen + gap;
    }
    // Bottom edge
    x = rect.left;
    while (x < rect.right) {
      canvas.drawLine(
        Offset(x, rect.bottom),
        Offset((x + dashLen).clamp(rect.left, rect.right), rect.bottom),
        paint,
      );
      x += dashLen + gap;
    }
    // Left edge
    double y = rect.top;
    while (y < rect.bottom) {
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.left, (y + dashLen).clamp(rect.top, rect.bottom)),
        paint,
      );
      y += dashLen + gap;
    }
    // Right edge
    y = rect.top;
    while (y < rect.bottom) {
      canvas.drawLine(
        Offset(rect.right, y),
        Offset(rect.right, (y + dashLen).clamp(rect.top, rect.bottom)),
        paint,
      );
      y += dashLen + gap;
    }
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

  void _drawPlatform(Canvas canvas, PlatformElement platform) {
    final w = platform.width * pixelsPerFt;
    final d = platform.depth * pixelsPerFt;
    final left = platform.positionX * pixelsPerFt;
    final top = platform.positionY * pixelsPerFt;
    final rect = Rect.fromLTWH(left, top, w, d);
    platformRects[platform.id] = rect;
    // Subtle drop shadow
    canvas.drawRect(
      rect.translate(2, 2),
      Paint()..color = Colors.black.withValues(alpha: 0.12)..style = PaintingStyle.fill,
    );
    // Khaki fill
    canvas.drawRect(rect, Paint()..color = const Color(0xFFC8B89A).withValues(alpha: 0.4)..style = PaintingStyle.fill);
    // Border
    canvas.drawRect(rect, Paint()..color = const Color(0xFF9B8B6E)..strokeWidth = 1.5..style = PaintingStyle.stroke);
    // Elevation label
    final label = '+${platform.elevation.toStringAsFixed(1)}ft';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF7A6845)),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 4);
    tp.paint(canvas, Offset(left + (w - tp.width) / 2, top + (d - tp.height) / 2));
  }

  void _drawMannequin(Canvas canvas, Mannequin mannequin) {
    final cx = mannequin.positionX * pixelsPerFt;
    final cy = mannequin.positionY * pixelsPerFt;
    mannequinRects[mannequin.id] = Rect.fromCenter(center: Offset(cx, cy), width: 32, height: 36);
    const accentColor = AppTheme.accent;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = accentColor;
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = accentColor;

    if (mannequin.mannequinType == 'leg_form') {
      // Two vertical parallel lines
      canvas.drawLine(Offset(cx - 4, cy - 10), Offset(cx - 4, cy + 10), strokePaint);
      canvas.drawLine(Offset(cx + 4, cy - 10), Offset(cx + 4, cy + 10), strokePaint);
    } else if (mannequin.mannequinType == 'bra_form') {
      // Horizontal bar with two small arcs
      canvas.drawLine(Offset(cx - 8, cy), Offset(cx + 8, cy), strokePaint);
      final rect1 = Rect.fromCircle(center: Offset(cx - 4, cy), radius: 5);
      final rect2 = Rect.fromCircle(center: Offset(cx + 4, cy), radius: 5);
      canvas.drawArc(rect1, -3.14159, 3.14159, false, strokePaint);
      canvas.drawArc(rect2, -3.14159, 3.14159, false, strokePaint);
    } else {
      // Standard figure: head + body lines
      // Head
      canvas.drawCircle(Offset(cx, cy - 9), 4, fillPaint);
      // Body
      canvas.drawLine(Offset(cx, cy - 5), Offset(cx, cy + 5), strokePaint);
      if (mannequin.mannequinType == 'full_body') {
        // Arms
        canvas.drawLine(Offset(cx - 7, cy - 2), Offset(cx + 7, cy - 2), strokePaint);
        // Legs
        canvas.drawLine(Offset(cx, cy + 5), Offset(cx - 5, cy + 13), strokePaint);
        canvas.drawLine(Offset(cx, cy + 5), Offset(cx + 5, cy + 13), strokePaint);
      } else if (mannequin.mannequinType == 'half_body') {
        // Arms only, no legs
        canvas.drawLine(Offset(cx - 7, cy - 2), Offset(cx + 7, cy - 2), strokePaint);
      }
      // torso: just head + body, no arms/legs
    }

    // Label below figure
    final label = mannequin.outfitName ?? mannequin.name ?? _mannequinAbbrev(mannequin.mannequinType);
    final tp = TextPainter(
      text: TextSpan(
        text: label.toUpperCase(),
        style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: AppTheme.accent),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 60);
    tp.paint(canvas, Offset(cx - tp.width / 2, cy + 15));
  }

  String _mannequinAbbrev(String type) {
    switch (type) {
      case 'full_body': return 'FULL';
      case 'half_body': return 'HALF';
      case 'torso': return 'TORSO';
      case 'leg_form': return 'LEGS';
      case 'bra_form': return 'BRA';
      default: return type.toUpperCase();
    }
  }

  void _drawSceneProp(Canvas canvas, SceneProp prop) {
    final w = prop.width * pixelsPerFt;
    final d = prop.depth * pixelsPerFt;
    final left = prop.positionX * pixelsPerFt;
    final top = prop.positionY * pixelsPerFt;
    final rect = Rect.fromLTWH(left, top, w, d);
    propRects[prop.id] = rect;
    const propColor = Color(0xFF2D6A4F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = propColor.withValues(alpha: 0.15)..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = propColor..strokeWidth = 1.2..style = PaintingStyle.stroke,
    );
    final label = _propAbbrev(prop.propType);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: propColor),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 4);
    tp.paint(canvas, Offset(left + (w - tp.width) / 2, top + (d - tp.height) / 2));
  }

  String _propAbbrev(String type) {
    switch (type) {
      case 'plant': return 'PLT';
      case 'furniture': return 'FURN';
      case 'riser': return 'RISR';
      case 'signage': return 'SIGN';
      default: return 'PROP';
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
    final angle = fixture.rotation * math.pi / 180;
    final cx = rect.center.dx;
    final cy = rect.center.dy;

    // Handle size and offset scaled to appear constant on screen regardless of zoom.
    final hs = (20.0 / viewScale).clamp(14.0, 60.0);
    // Offset from fixture edge so handles sit fully outside the body.
    final ho = hs / 2 + (3.0 / viewScale).clamp(2.0, 8.0);

    Offset toScreen(Offset local) {
      final dx = local.dx - cx;
      final dy = local.dy - cy;
      return Offset(
        cx + dx * math.cos(angle) - dy * math.sin(angle),
        cy + dx * math.sin(angle) + dy * math.cos(angle),
      );
    }

    final handles = _handlesForType(fixture.fixtureType);
    final handleRects = <String, Rect>{};
    for (final h in handles) {
      Offset localCenter;
      switch (h) {
        case 'top':
          localCenter = Offset(rect.center.dx, rect.top - ho);
        case 'bottom':
          localCenter = Offset(rect.center.dx, rect.bottom + ho);
        case 'left':
          localCenter = Offset(rect.left - ho, rect.center.dy);
        case 'right':
          localCenter = Offset(rect.right + ho, rect.center.dy);
        default:
          continue;
      }
      final screenCenter = toScreen(localCenter);
      final hr = Rect.fromCenter(center: screenCenter, width: hs, height: hs);
      handleRects[h] = hr;
      canvas.drawRRect(
        RRect.fromRectAndRadius(hr, const Radius.circular(4)),
        Paint()..color = AppTheme.accent..style = PaintingStyle.fill,
      );
      final double dirAngle;
      switch (h) {
        case 'left' || 'right': dirAngle = angle;
        case 'top' || 'bottom': dirAngle = angle + math.pi / 2;
        default: dirAngle = angle;
      }
      _drawArrow(canvas, screenCenter, dirAngle);
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

  // Rotates [pt] around [center] by [angle] radians.
  static Offset _rotateAround(Offset pt, Offset center, double angle) {
    final dx = pt.dx - center.dx;
    final dy = pt.dy - center.dy;
    return Offset(
      center.dx + dx * math.cos(angle) - dy * math.sin(angle),
      center.dy + dx * math.sin(angle) + dy * math.cos(angle),
    );
  }

  // Draws a double-headed arrow centred at [center] along direction [dirAngle] (radians).
  void _drawArrow(Canvas canvas, Offset center, double dirAngle) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const arm = 4.0;
    const barb = 2.0;
    final cosA = math.cos(dirAngle);
    final sinA = math.sin(dirAngle);
    final tip1 = Offset(center.dx - cosA * arm, center.dy - sinA * arm);
    final tip2 = Offset(center.dx + cosA * arm, center.dy + sinA * arm);
    canvas.drawLine(tip1, tip2, paint);
    // Barbs at tip1 (toward tip2)
    final b1x = tip1.dx + cosA * 2; final b1y = tip1.dy + sinA * 2;
    canvas.drawLine(tip1, Offset(b1x + sinA * barb, b1y - cosA * barb), paint);
    canvas.drawLine(tip1, Offset(b1x - sinA * barb, b1y + cosA * barb), paint);
    // Barbs at tip2 (toward tip1)
    final b2x = tip2.dx - cosA * 2; final b2y = tip2.dy - sinA * 2;
    canvas.drawLine(tip2, Offset(b2x + sinA * barb, b2y - cosA * barb), paint);
    canvas.drawLine(tip2, Offset(b2x - sinA * barb, b2y + cosA * barb), paint);
  }

  void _drawPlanogramBadges(Canvas canvas, Fixture fixture) {
    if (fixture.fixtureType == 'wall') return; // structural — no planogram
    final rect = fixtureRects[fixture.id];
    if (rect == null) return;
    final angle = fixture.rotation * math.pi / 180;
    Offset rotated(Offset local) => _rotateAround(local, rect.center, angle);
    if (fixture.fixtureType == 'partition') {
      _drawPartitionBadges(canvas, fixture, rect, rotated);
    } else {
      final anchor = rotated(Offset(rect.right - 2, rect.bottom - 2));
      final badgeRect = _badgeRect(anchor, anchor: 'bottomRight');
      badgeRects[fixture.id] = badgeRect;
      _paintBadge(canvas, badgeRect, fixture.planogramId, planograms[fixture.planogramId]?.title);
    }
  }

  void _drawPartitionBadges(Canvas canvas, Fixture fixture, Rect rect,
      Offset Function(Offset) rotated) {
    final isWide = rect.width >= rect.height;
    if (isWide) {
      final frontRect = _badgeRect(
          rotated(Offset(rect.center.dx, rect.bottom - 2)), anchor: 'bottomCenter');
      badgeRects[fixture.id] = frontRect;
      _paintBadge(canvas, frontRect, fixture.planogramId, planograms[fixture.planogramId]?.title);
      if (!fixture.wallAdjacent) {
        final backRect = _badgeRect(
            rotated(Offset(rect.center.dx, rect.top + 2)), anchor: 'topCenter');
        badgeBackRects[fixture.id] = backRect;
        _paintBadge(canvas, backRect, fixture.planogramIdBack, planograms[fixture.planogramIdBack]?.title);
      }
    } else {
      final frontRect = _badgeRect(
          rotated(Offset(rect.right - 2, rect.center.dy)), anchor: 'rightCenter');
      badgeRects[fixture.id] = frontRect;
      _paintBadge(canvas, frontRect, fixture.planogramId, planograms[fixture.planogramId]?.title);
      if (!fixture.wallAdjacent) {
        final backRect = _badgeRect(
            rotated(Offset(rect.left + 2, rect.center.dy)), anchor: 'leftCenter');
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
    final bgColor = isAssigned ? AppTheme.accent : Colors.grey.shade400;
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
      old.ghostType != ghostType ||
      old.viewScale != viewScale ||
      old.wallEdges != wallEdges ||
      old.planograms != planograms ||
      old.mannequins != mannequins ||
      old.platforms != platforms ||
      old.sceneProps != sceneProps ||
      old.selectedFixtureIds != selectedFixtureIds;
}
