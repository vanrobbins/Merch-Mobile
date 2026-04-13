import 'package:flutter/material.dart';
import '../../core/models/store_zone.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class ZoneMapPainter extends CustomPainter {
  ZoneMapPainter({
    required this.zones,
    this.selectedZoneId,
    required this.onZoneTap,
  });

  final List<StoreZone> zones;
  final String? selectedZoneId;
  final void Function(String zoneId) onZoneTap;

  final Map<String, Rect> _zoneRects = {};

  @override
  void paint(Canvas canvas, Size size) {
    _zoneRects.clear();
    _drawGrid(canvas, size);
    _drawZones(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawZones(Canvas canvas, Size size) {
    for (final zone in zones) {
      final rect = Rect.fromLTWH(
        zone.posX * size.width,
        zone.posY * size.height,
        zone.width * size.width,
        zone.height * size.height,
      );
      _zoneRects[zone.id] = rect;

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(AppTheme.borderRadius));
      final isSelected = zone.id == selectedZoneId;

      // Fill
      final fillPaint = Paint()
        ..color = Color(zone.colorValue).withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      // Border
      final borderPaint = Paint()
        ..color = isSelected ? AppTheme.accent : Color(zone.colorValue)
        ..strokeWidth = isSelected ? 2.0 : 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rrect, borderPaint);

      // Label
      _drawLabel(canvas, zone.name, rect);
    }
  }

  void _drawLabel(Canvas canvas, String text, Rect rect) {
    final span = TextSpan(
      text: text.toUpperCase(),
      style: const TextStyle(
        fontSize: DesignTokens.typeXs,
        fontWeight: DesignTokens.weightBold,
        letterSpacing: DesignTokens.letterSpacingEyebrow,
        color: AppTheme.textPrimary,
      ),
    );
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 8);

    final offset = Offset(
      rect.left + (rect.width - tp.width) / 2,
      rect.top + (rect.height - tp.height) / 2,
    );
    tp.paint(canvas, offset);
  }

  @override
  bool? hitTest(Offset position) {
    for (final entry in _zoneRects.entries) {
      if (entry.value.contains(position)) {
        onZoneTap(entry.key);
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldRepaint(ZoneMapPainter old) =>
      old.zones != zones || old.selectedZoneId != selectedZoneId;
}
