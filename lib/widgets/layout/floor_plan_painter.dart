import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/schematic_project.dart';
import '../../models/display_section.dart';
import '../../models/store_zone.dart';
import '../../theme/app_theme.dart';

/// Renders a bird's-eye store floor plan on a [Canvas].
///
/// • Store footprint: arbitrary polygon (normalised 0–1 coords).
/// • Coloured zone regions covering the polygon area.
/// • Fixtures: wall sections drawn on the perimeter walls,
///   tables and racks drawn as icons on the floor.
/// • Selected section highlighted.
/// • Calls [onSectionHit] when the user taps near a section fixture.
class FloorPlanPainter extends CustomPainter {
  final SchematicProject project;
  final String? selectedSectionId;
  final void Function(String sectionId, Offset localPos)? onSectionHit;

  /// Hit-test rects populated during paint; used by [hitTest].
  final Map<String, Rect> _sectionRects = {};

  FloorPlanPainter({
    required this.project,
    this.selectedSectionId,
    this.onSectionHit,
  });

  // ── Coordinate helpers ────────────────────────────────────────────────────

  /// Converts a normalised store point (0–1) to canvas pixels.
  Offset _toCanvas(StorePoint p, Rect floorRect) {
    return Offset(
      floorRect.left + p.x * floorRect.width,
      floorRect.top + p.y * floorRect.height,
    );
  }

  /// Converts a canvas pixel to normalised store coords.
  static StorePoint canvasToNorm(Offset pos, Rect floorRect) {
    return StorePoint(
      ((pos.dx - floorRect.left) / floorRect.width).clamp(0.0, 1.0),
      ((pos.dy - floorRect.top) / floorRect.height).clamp(0.0, 1.0),
    );
  }

  /// The floor rect within the full canvas (leaves margin for labels).
  static Rect floorRect(Size canvasSize) {
    const margin = 40.0;
    return Rect.fromLTRB(margin, margin,
        canvasSize.width - margin, canvasSize.height - margin);
  }

  // ── Build the store polygon as a Path ──────────────────────────────────────
  Path _buildPolygon(Rect fr) {
    final pts = project.storePolygon;
    if (pts.isEmpty) return Path()..addRect(fr);
    final path = Path();
    path.moveTo(_toCanvas(pts.first, fr).dx, _toCanvas(pts.first, fr).dy);
    for (final p in pts.skip(1)) {
      final c = _toCanvas(p, fr);
      path.lineTo(c.dx, c.dy);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _sectionRects.clear();
    final fr = floorRect(size);

    // ── Background grid ───────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0xFFDDDDCC)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const gridStep = 40.0;
    for (double x = fr.left; x <= fr.right; x += gridStep) {
      canvas.drawLine(Offset(x, fr.top), Offset(x, fr.bottom), gridPaint);
    }
    for (double y = fr.top; y <= fr.bottom; y += gridStep) {
      canvas.drawLine(Offset(fr.left, y), Offset(fr.right, y), gridPaint);
    }

    // ── Store polygon (floor fill) ────────────────────────────────────────
    final polygon = _buildPolygon(fr);

    final floorFill = Paint()
      ..color = const Color(0xFFF5F3EE)
      ..style = PaintingStyle.fill;
    canvas.drawPath(polygon, floorFill);

    // Clip all subsequent drawing to the store polygon.
    canvas.save();
    canvas.clipPath(polygon);

    // ── Zone fills ────────────────────────────────────────────────────────
    _drawZones(canvas, fr);

    canvas.restore();

    // ── Store outline (walls) ─────────────────────────────────────────────
    final wallPaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter;
    canvas.drawPath(polygon, wallPaint);

    // ── Dimension labels ──────────────────────────────────────────────────
    _drawDimensions(canvas, fr);

    // ── Wall sections (perimeter) ─────────────────────────────────────────
    _drawPerimeterSections(canvas, fr);

    // ── Floor fixtures (tables, racks) ────────────────────────────────────
    _drawFloorFixtures(canvas, fr);

    // ── Compass rose ─────────────────────────────────────────────────────
    _drawCompass(canvas, size);

    // ── Zone name labels (above zones) ────────────────────────────────────
    _drawZoneLabels(canvas, fr);
  }

  // ── Zone fills ────────────────────────────────────────────────────────────

  void _drawZones(Canvas canvas, Rect fr) {
    for (final zone in project.zones) {
      final color = Color(zone.colorValue).withAlpha(38);
      final sections = project.sectionsInZone(zone.id);
      if (sections.isEmpty) continue;

      final zoneFill = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Compute a convex hull / bounding rect of all sections in this zone.
      // Simple approach: union of fixture rects.
      Rect? unionRect;
      for (final s in sections) {
        final r = _sectionBounds(s, fr);
        unionRect = unionRect == null ? r : unionRect.expandToInclude(r);
      }
      if (unionRect != null) {
        final inflated = unionRect.inflate(12);
        canvas.drawRRect(
          RRect.fromRectAndRadius(inflated, const Radius.circular(6)),
          zoneFill,
        );
        // Zone border
        canvas.drawRRect(
          RRect.fromRectAndRadius(inflated, const Radius.circular(6)),
          Paint()
            ..color = Color(zone.colorValue).withAlpha(100)
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  void _drawZoneLabels(Canvas canvas, Rect fr) {
    for (final zone in project.zones) {
      final sections = project.sectionsInZone(zone.id);
      if (sections.isEmpty) continue;

      Rect? unionRect;
      for (final s in sections) {
        final r = _sectionBounds(s, fr);
        unionRect = unionRect == null ? r : unionRect.expandToInclude(r);
      }
      if (unionRect == null) continue;

      final inflated = unionRect.inflate(12);
      final labelPos = Offset(inflated.left + 6, inflated.top + 4);

      final tp = TextPainter(
        text: TextSpan(
          text: zone.name.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Color(zone.colorValue),
            letterSpacing: 0.6,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelPos);
    }
  }

  // ── Dimensions ────────────────────────────────────────────────────────────

  void _drawDimensions(Canvas canvas, Rect fr) {
    final dimStyle = TextStyle(
      fontSize: 10,
      color: AppTheme.textSecondary,
    );
    // Width label (bottom)
    _drawText(
      canvas,
      '${project.storeWidthFt.toStringAsFixed(0)}ft wide',
      Offset(fr.center.dx, fr.bottom + 12),
      dimStyle,
      align: TextAlign.center,
    );
    // Depth label (right, rotated)
    canvas.save();
    canvas.translate(fr.right + 14, fr.center.dy);
    canvas.rotate(math.pi / 2);
    _drawText(
      canvas,
      '${project.storeDepthFt.toStringAsFixed(0)}ft deep',
      Offset.zero,
      dimStyle,
      align: TextAlign.center,
    );
    canvas.restore();
  }

  // ── Perimeter sections ────────────────────────────────────────────────────

  void _drawPerimeterSections(Canvas canvas, Rect fr) {
    final walls = project.sections
        .where((s) =>
            s.type == SectionType.perimeter && s.wallSide != WallSide.none)
        .toList();

    for (final s in walls) {
      final rect = _wallSectionRect(s, fr);
      _sectionRects[s.id] = rect;
      _drawWallFixture(canvas, s, rect);
    }

    // Unassigned perimeter sections: draw as small stubs at top-left corner
    final unassigned = project.sections
        .where((s) =>
            s.type == SectionType.perimeter && s.wallSide == WallSide.none)
        .toList();
    for (int i = 0; i < unassigned.length; i++) {
      final s = unassigned[i];
      final y = fr.top + 8 + i * 14.0;
      final rect = Rect.fromLTWH(fr.left + 4, y, 60, 12);
      _sectionRects[s.id] = rect;
      _drawUnassignedStub(canvas, s, rect);
    }
  }

  Rect _wallSectionRect(DisplaySection s, Rect fr) {
    final lf = (s.linearFeet ?? 8).toDouble();
    // Map LF to pixel width (48LF = full wall width)
    final maxLf = 48.0;
    final frac = (lf / maxLf).clamp(0.0, 1.0);

    const thickness = 12.0;
    const minPos = 0.0;
    final pos = s.layoutPosition.clamp(0.0, 1.0);

    switch (s.wallSide) {
      case WallSide.north:
        final wallW = fr.width * frac;
        final x = fr.left + fr.width * pos;
        return Rect.fromLTWH(x, fr.top - thickness / 2, wallW, thickness);
      case WallSide.south:
        final wallW = fr.width * frac;
        final x = fr.left + fr.width * pos;
        return Rect.fromLTWH(
            x, fr.bottom - thickness / 2, wallW, thickness);
      case WallSide.east:
        final wallH = fr.height * frac;
        final y = fr.top + fr.height * pos;
        return Rect.fromLTWH(
            fr.right - thickness / 2, y, thickness, wallH);
      case WallSide.west:
        final wallH = fr.height * frac;
        final y = fr.top + fr.height * pos;
        return Rect.fromLTWH(fr.left - thickness / 2, y, thickness, wallH);
      case WallSide.none:
        return Rect.fromLTWH(fr.left, fr.top, 60, 12);
    }
  }

  void _drawWallFixture(Canvas canvas, DisplaySection s, Rect rect) {
    final isSelected = s.id == selectedSectionId;
    final zoneColor = _zoneColor(s.zoneId);

    // Fixture bar
    final bg = Paint()
      ..color = isSelected
          ? AppTheme.accent.withAlpha(220)
          : (zoneColor?.withAlpha(200) ?? AppTheme.primary.withAlpha(180))
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, bg);

    // Hatch pattern for wall
    final hatch = Paint()
      ..color = Colors.white.withAlpha(60)
      ..strokeWidth = 1;
    for (double t = 0; t < rect.width + rect.height; t += 6) {
      canvas.drawLine(
        Offset(rect.left + t, rect.top),
        Offset(rect.left, rect.top + t),
        hatch,
      );
    }

    // Border
    canvas.drawRect(
      rect,
      Paint()
        ..color = isSelected ? AppTheme.accent : AppTheme.primary
        ..strokeWidth = isSelected ? 2.0 : 1.0
        ..style = PaintingStyle.stroke,
    );

    // LF label
    final isHoriz =
        s.wallSide == WallSide.north || s.wallSide == WallSide.south;
    if (isHoriz && rect.width > 30) {
      _drawText(
        canvas,
        '${s.linearFeet ?? 8}LF',
        rect.center,
        const TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        align: TextAlign.center,
      );
    } else if (!isHoriz && rect.height > 30) {
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(math.pi / 2);
      _drawText(
        canvas,
        '${s.linearFeet ?? 8}LF',
        Offset.zero,
        const TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        align: TextAlign.center,
      );
      canvas.restore();
    }
  }

  void _drawUnassignedStub(Canvas canvas, DisplaySection s, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()
        ..color = AppTheme.textTertiary.withAlpha(60)
        ..style = PaintingStyle.fill,
    );
    _drawText(
      canvas,
      s.title,
      Offset(rect.left + 3, rect.top + 2),
      const TextStyle(
        fontSize: 7,
        color: AppTheme.textSecondary,
      ),
    );
  }

  // ── Floor fixtures ────────────────────────────────────────────────────────

  void _drawFloorFixtures(Canvas canvas, Rect fr) {
    final floor = project.sections
        .where((s) => s.type != SectionType.perimeter || s.wallSide == WallSide.none)
        .where((s) => s.type != SectionType.perimeter)
        .toList();

    for (final s in floor) {
      final center = Offset(
        fr.left + s.layoutX * fr.width,
        fr.top + s.layoutY * fr.height,
      );
      final rect = s.type == SectionType.table
          ? _tableRect(center)
          : _rackRect(center);

      _sectionRects[s.id] = rect;
      if (s.type == SectionType.table) {
        _drawTableFixture(canvas, s, rect);
      } else {
        _drawRackFixture(canvas, s, rect);
      }
    }
  }

  Rect _tableRect(Offset center) =>
      Rect.fromCenter(center: center, width: 56, height: 36);

  Rect _rackRect(Offset center) =>
      Rect.fromCenter(center: center, width: 36, height: 36);

  void _drawTableFixture(Canvas canvas, DisplaySection s, Rect rect) {
    final isSelected = s.id == selectedSectionId;
    final zoneColor = _zoneColor(s.zoneId);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = isSelected
            ? AppTheme.accent.withAlpha(230)
            : (zoneColor?.withAlpha(180) ?? const Color(0xFFAA8855))
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = isSelected ? AppTheme.accent : const Color(0xFF775533)
        ..strokeWidth = isSelected ? 2.0 : 1.0
        ..style = PaintingStyle.stroke,
    );

    // Table leg dots
    final dot = Paint()
      ..color = Colors.white.withAlpha(120)
      ..style = PaintingStyle.fill;
    for (final p in [
      rect.topLeft.translate(5, 5),
      rect.topRight.translate(-5, 5),
      rect.bottomLeft.translate(5, -5),
      rect.bottomRight.translate(-5, -5),
    ]) {
      canvas.drawCircle(p, 2, dot);
    }

    // Label
    _drawText(
      canvas,
      '📋',
      rect.topCenter.translate(0, 4),
      const TextStyle(fontSize: 10),
      align: TextAlign.center,
    );
    if (rect.width > 40) {
      _drawText(
        canvas,
        _shortTitle(s.title),
        rect.bottomCenter.translate(0, -8),
        const TextStyle(
          fontSize: 6.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        align: TextAlign.center,
      );
    }
  }

  void _drawRackFixture(Canvas canvas, DisplaySection s, Rect rect) {
    final isSelected = s.id == selectedSectionId;
    final zoneColor = _zoneColor(s.zoneId);
    final center = rect.center;
    final r = rect.width / 2;

    // Circle for rack
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = isSelected
            ? AppTheme.accent.withAlpha(230)
            : (zoneColor?.withAlpha(180) ?? AppTheme.rackerColor)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = isSelected ? AppTheme.accent : const Color(0xFF777777)
        ..strokeWidth = isSelected ? 2.0 : 1.0
        ..style = PaintingStyle.stroke,
    );

    // Cross inside
    canvas.drawLine(
      center.translate(-r * 0.6, 0),
      center.translate(r * 0.6, 0),
      Paint()
        ..color = Colors.white.withAlpha(150)
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      center.translate(0, -r * 0.6),
      center.translate(0, r * 0.6),
      Paint()
        ..color = Colors.white.withAlpha(150)
        ..strokeWidth = 1.5,
    );

    _drawText(
      canvas,
      '🎣',
      center.translate(0, -6),
      const TextStyle(fontSize: 10),
      align: TextAlign.center,
    );
  }

  // ── Compass rose ──────────────────────────────────────────────────────────

  void _drawCompass(Canvas canvas, Size size) {
    const r = 16.0;
    final center = Offset(size.width - r - 8, r + 8);
    final bg = Paint()
      ..color = Colors.white.withAlpha(200)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r, bg);
    canvas.drawCircle(
        center, r, Paint()..color = AppTheme.outline..style = PaintingStyle.stroke);

    const dirs = {'N': Offset(0, -1), 'S': Offset(0, 1), 'E': Offset(1, 0), 'W': Offset(-1, 0)};
    for (final e in dirs.entries) {
      final pos = center + e.value * (r - 6);
      _drawText(canvas, e.key, pos,
          TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: e.key == 'N' ? AppTheme.accent : AppTheme.textPrimary,
          ),
          align: TextAlign.center);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Rect _sectionBounds(DisplaySection s, Rect fr) {
    if (s.type == SectionType.perimeter && s.wallSide != WallSide.none) {
      return _wallSectionRect(s, fr);
    }
    final center = Offset(
      fr.left + s.layoutX * fr.width,
      fr.top + s.layoutY * fr.height,
    );
    return s.type == SectionType.table ? _tableRect(center) : _rackRect(center);
  }

  Color? _zoneColor(String? zoneId) {
    if (zoneId == null) return null;
    final zone = project.getZone(zoneId);
    return zone != null ? Color(zone.colorValue) : null;
  }

  String _shortTitle(String title) {
    if (title.length <= 12) return title;
    return '${title.substring(0, 11)}…';
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    TextStyle style, {
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    final drawPos = align == TextAlign.center
        ? pos.translate(-tp.width / 2, -tp.height / 2)
        : pos;
    tp.paint(canvas, drawPos);
  }

  // ── Hit testing ───────────────────────────────────────────────────────────

  String? hitTest(Offset localPos, Size size) {
    final fr = floorRect(size);
    // Repopulate rects (paint may not have run yet).
    _populateRects(fr);
    for (final entry in _sectionRects.entries) {
      if (entry.value.inflate(8).contains(localPos)) return entry.key;
    }
    return null;
  }

  void _populateRects(Rect fr) {
    _sectionRects.clear();
    for (final s in project.sections) {
      _sectionRects[s.id] = _sectionBounds(s, fr);
    }
  }

  @override
  bool shouldRepaint(FloorPlanPainter old) =>
      old.project != project || old.selectedSectionId != selectedSectionId;
}
