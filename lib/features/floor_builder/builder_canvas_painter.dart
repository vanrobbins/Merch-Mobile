import 'package:flutter/material.dart';
import '../../core/models/fixture.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

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
  });

  final List<Fixture> fixtures;
  final String? selectedFixtureId;
  final Offset? ghostPos;
  final String? ghostType;
  final double pixelsPerFt;
  final List<Offset>? zoneNormalizedPts;
  final Color? zoneColor;
  final String? zoneName;

  final Map<String, Rect> fixtureRects = {};

  @override
  void paint(Canvas canvas, Size size) {
    fixtureRects.clear();
    _drawZoneBackground(canvas, size);
    for (final fixture in fixtures) {
      _drawFixture(canvas, fixture);
    }
    if (ghostPos != null && ghostType != null) {
      _drawGhost(canvas, ghostPos!, ghostType!);
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
    // Thick filled rect
    final wallPaint = Paint()..color = AppTheme.primary.withValues(alpha: 0.35)..style = PaintingStyle.fill;
    canvas.drawRect(rect, wallPaint);
    canvas.drawRect(rect, border);
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

  @override
  bool shouldRepaint(BuilderCanvasPainter old) =>
      old.fixtures != fixtures ||
      old.selectedFixtureId != selectedFixtureId ||
      old.ghostPos != ghostPos;
}
