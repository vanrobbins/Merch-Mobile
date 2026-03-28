import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Draws a wall-mounted perimeter rack system:
///  • Two vertical upright poles
///  • Horizontal shelf at top (wood-coloured)
///  • One or two hanging rods below the shelf
class WallRackPainter extends CustomPainter {
  final int uprightCount;
  final bool hasTopShelf;

  const WallRackPainter({
    this.uprightCount = 2,
    this.hasTopShelf = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final metalPaint = Paint()
      ..color = AppTheme.rackerColor
      ..style = PaintingStyle.fill;

    final metalStroke = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final shelfPaint = Paint()
      ..color = AppTheme.shelfColor
      ..style = PaintingStyle.fill;

    final shelfStroke = Paint()
      ..color = const Color(0xFF9A7A50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const poleW = 6.0;
    const capSize = 10.0;
    const shelfH = 10.0;
    const rodH = 5.0;

    // Column positions (evenly spaced)
    final step = w / (uprightCount + 1);
    final poleXs = List.generate(uprightCount + 2, (i) => i * step);

    // ── Upright poles ─────────────────────────────────────────────────────
    for (final x in poleXs) {
      // Cap on top
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - capSize / 2, 0, capSize, capSize),
          const Radius.circular(2),
        ),
        metalPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - capSize / 2, 0, capSize, capSize),
          const Radius.circular(2),
        ),
        metalStroke,
      );

      // Pole shaft
      canvas.drawRect(
        Rect.fromLTWH(x - poleW / 2, capSize, poleW, h - capSize),
        metalPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(x - poleW / 2, capSize, poleW, h - capSize),
        metalStroke,
      );
    }

    // ── Top shelf (wood) ──────────────────────────────────────────────────
    if (hasTopShelf) {
      final shelfY = h * 0.18;
      canvas.drawRect(
        Rect.fromLTWH(poleXs.first - 4, shelfY, w + 8, shelfH),
        shelfPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(poleXs.first - 4, shelfY, w + 8, shelfH),
        shelfStroke,
      );
    }

    // ── Mid shelf (wood) ──────────────────────────────────────────────────
    final midShelfY = h * 0.52;
    canvas.drawRect(
      Rect.fromLTWH(poleXs.first - 4, midShelfY, w + 8, shelfH),
      shelfPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(poleXs.first - 4, midShelfY, w + 8, shelfH),
      shelfStroke,
    );

    // ── Upper hanging rod ─────────────────────────────────────────────────
    final upperRodY = h * 0.33;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(poleXs.first - 2, upperRodY, w + 4, rodH),
        const Radius.circular(2),
      ),
      metalPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(poleXs.first - 2, upperRodY, w + 4, rodH),
        const Radius.circular(2),
      ),
      metalStroke,
    );

    // ── Lower hanging rod ─────────────────────────────────────────────────
    final lowerRodY = h * 0.68;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(poleXs.first - 2, lowerRodY, w + 4, rodH),
        const Radius.circular(2),
      ),
      metalPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(poleXs.first - 2, lowerRodY, w + 4, rodH),
        const Radius.circular(2),
      ),
      metalStroke,
    );

    // ── Base caps ─────────────────────────────────────────────────────────
    for (final x in poleXs) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - capSize / 2, h - capSize, capSize, capSize),
          const Radius.circular(2),
        ),
        metalPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - capSize / 2, h - capSize, capSize, capSize),
          const Radius.circular(2),
        ),
        metalStroke,
      );
    }
  }

  @override
  bool shouldRepaint(WallRackPainter old) =>
      old.uprightCount != uprightCount || old.hasTopShelf != hasTopShelf;
}

/// Draws a T-bar / U-bar floor rack:
///  • Vertical centre pole
///  • Two horizontal arms at the top forming a T
///  • Base feet
class TBarRackPainter extends CustomPainter {
  const TBarRackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final metal = Paint()
      ..color = AppTheme.rackerColor
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const poleW = 6.0;

    // Centre pole
    canvas.drawRect(
      Rect.fromLTWH(w / 2 - poleW / 2, 0, poleW, h * 0.88),
      metal,
    );
    canvas.drawRect(
      Rect.fromLTWH(w / 2 - poleW / 2, 0, poleW, h * 0.88),
      stroke,
    );

    // Crossbar at top
    final crossbarY = h * 0.08;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, crossbarY, w, 6),
        const Radius.circular(3),
      ),
      metal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, crossbarY, w, 6),
        const Radius.circular(3),
      ),
      stroke,
    );

    // Mid crossbar
    final midBarY = h * 0.48;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, midBarY, w * 0.8, 5),
        const Radius.circular(2),
      ),
      metal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, midBarY, w * 0.8, 5),
        const Radius.circular(2),
      ),
      stroke,
    );

    // Base feet
    final baseY = h * 0.88;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, baseY, w * 0.7, 8),
        const Radius.circular(4),
      ),
      metal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, baseY, w * 0.7, 8),
        const Radius.circular(4),
      ),
      stroke,
    );

    // Foot ends
    for (final x in [w * 0.2, w * 0.8]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 6, baseY + 4, 12, 12),
          const Radius.circular(2),
        ),
        metal,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 6, baseY + 4, 12, 12),
          const Radius.circular(2),
        ),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(TBarRackPainter _) => false;
}

/// Draws a clothes hanger icon.
class HangerPainter extends CustomPainter {
  final Color color;

  const HangerPainter({this.color = const Color(0xFF888888)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Hook
    final hook = Path()
      ..moveTo(w * 0.5, h * 0.15)
      ..quadraticBezierTo(w * 0.65, h * 0.02, w * 0.75, h * 0.1)
      ..quadraticBezierTo(w * 0.82, h * 0.18, w * 0.7, h * 0.25);
    canvas.drawPath(hook, p);

    // Neck
    canvas.drawLine(Offset(w * 0.5, h * 0.15), Offset(w * 0.5, h * 0.32), p);

    // Shoulders
    final shoulders = Path()
      ..moveTo(w * 0.5, h * 0.32)
      ..quadraticBezierTo(w * 0.35, h * 0.38, 0, h * 0.7)
      ..moveTo(w * 0.5, h * 0.32)
      ..quadraticBezierTo(w * 0.65, h * 0.38, w, h * 0.7);
    canvas.drawPath(shoulders, p);

    // Bar
    canvas.drawLine(Offset(0, h * 0.7), Offset(w, h * 0.7), p);
  }

  @override
  bool shouldRepaint(HangerPainter old) => old.color != color;
}
