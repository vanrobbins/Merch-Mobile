import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/garment_type.dart';

/// Draws a flat-lay technical garment silhouette for the given [type] and [color].
/// Coordinate space is normalised to 100×100 internally and scaled to [size].
class GarmentPainter extends CustomPainter {
  final GarmentType type;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const GarmentPainter({
    required this.type,
    required this.fillColor,
    this.strokeColor = const Color(0xFF333333),
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 100;

    final fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.scale(sx, sy);

    switch (type) {
      case GarmentType.tshirt:
        _drawTshirt(canvas, fill, stroke);
      case GarmentType.hoodie:
        _drawHoodie(canvas, fill, stroke);
      case GarmentType.quarterZip:
        _drawQuarterZip(canvas, fill, stroke);
      case GarmentType.halfZip:
        _drawHalfZip(canvas, fill, stroke);
      case GarmentType.jacket:
        _drawJacket(canvas, fill, stroke);
      case GarmentType.jogger:
      case GarmentType.pants:
        _drawPants(canvas, fill, stroke);
      case GarmentType.shorts:
        _drawShorts(canvas, fill, stroke);
      case GarmentType.vest:
        _drawVest(canvas, fill, stroke);
      case GarmentType.hat:
        _drawHat(canvas, fill, stroke);
      case GarmentType.shoes:
        _drawShoes(canvas, fill, stroke);
      case GarmentType.accessory:
        _drawAccessory(canvas, fill, stroke);
    }

    canvas.restore();
  }

  // ── T-Shirt ──────────────────────────────────────────────────────────────
  void _drawTshirt(Canvas canvas, Paint fill, Paint stroke) {
    // Body
    final body = Path()
      ..moveTo(25, 28)
      ..lineTo(15, 22)
      ..lineTo(5, 28)
      ..lineTo(10, 45)
      ..lineTo(18, 42)
      ..lineTo(18, 95)
      ..lineTo(82, 95)
      ..lineTo(82, 42)
      ..lineTo(90, 45)
      ..lineTo(95, 28)
      ..lineTo(85, 22)
      ..lineTo(75, 28)
      // Neck
      ..quadraticBezierTo(70, 20, 60, 18)
      ..quadraticBezierTo(50, 16, 40, 18)
      ..quadraticBezierTo(30, 20, 25, 28)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Neck interior curve
    final neck = Path()
      ..moveTo(38, 22)
      ..quadraticBezierTo(50, 30, 62, 22);
    canvas.drawPath(neck, stroke);
  }

  // ── Hoodie ───────────────────────────────────────────────────────────────
  void _drawHoodie(Canvas canvas, Paint fill, Paint stroke) {
    // Body + sleeves
    final body = Path()
      ..moveTo(22, 35)
      ..lineTo(5, 30)
      ..lineTo(2, 55)
      ..lineTo(18, 58)
      ..lineTo(18, 97)
      ..lineTo(82, 97)
      ..lineTo(82, 58)
      ..lineTo(98, 55)
      ..lineTo(95, 30)
      ..lineTo(78, 35)
      // Hood outer edges
      ..quadraticBezierTo(72, 15, 60, 8)
      ..quadraticBezierTo(50, 4, 40, 8)
      ..quadraticBezierTo(28, 15, 22, 35)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Hood inner opening
    final hoodInner = Path()
      ..moveTo(35, 33)
      ..quadraticBezierTo(50, 24, 65, 33)
      ..quadraticBezierTo(62, 14, 50, 11)
      ..quadraticBezierTo(38, 14, 35, 33)
      ..close();
    canvas.drawPath(hoodInner, stroke);

    // Kangaroo pocket
    final pocket = Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(30, 68, 40, 22), const Radius.circular(3)));
    canvas.drawPath(pocket, stroke);

    // Drawstrings
    canvas.drawLine(const Offset(45, 33), const Offset(40, 55), stroke);
    canvas.drawLine(const Offset(55, 33), const Offset(60, 55), stroke);
  }

  // ── Quarter Zip ──────────────────────────────────────────────────────────
  void _drawQuarterZip(Canvas canvas, Paint fill, Paint stroke) {
    final body = Path()
      ..moveTo(22, 30)
      ..lineTo(8, 25)
      ..lineTo(3, 52)
      ..lineTo(18, 55)
      ..lineTo(18, 97)
      ..lineTo(82, 97)
      ..lineTo(82, 55)
      ..lineTo(97, 52)
      ..lineTo(92, 25)
      ..lineTo(78, 30)
      ..lineTo(72, 16)
      ..quadraticBezierTo(65, 12, 58, 13)
      ..lineTo(57, 22)
      ..lineTo(50, 24)
      ..lineTo(43, 22)
      ..lineTo(42, 13)
      ..quadraticBezierTo(35, 12, 28, 16)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Mock-neck collar
    final collar = Path()
      ..moveTo(43, 22)
      ..lineTo(43, 32)
      ..lineTo(57, 32)
      ..lineTo(57, 22);
    canvas.drawPath(collar, stroke);

    // Quarter zip line
    final zipLine = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth * 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(50, 32), const Offset(50, 56), zipLine);

    // Zip pull
    canvas.drawCircle(const Offset(50, 56), 2.5, fill);
    canvas.drawCircle(const Offset(50, 56), 2.5, stroke);
  }

  // ── Half Zip ─────────────────────────────────────────────────────────────
  void _drawHalfZip(Canvas canvas, Paint fill, Paint stroke) {
    final body = Path()
      ..moveTo(22, 30)
      ..lineTo(8, 25)
      ..lineTo(3, 52)
      ..lineTo(18, 55)
      ..lineTo(18, 97)
      ..lineTo(82, 97)
      ..lineTo(82, 55)
      ..lineTo(97, 52)
      ..lineTo(92, 25)
      ..lineTo(78, 30)
      ..lineTo(72, 15)
      ..quadraticBezierTo(65, 11, 58, 12)
      ..lineTo(57, 20)
      ..lineTo(50, 22)
      ..lineTo(43, 20)
      ..lineTo(42, 12)
      ..quadraticBezierTo(35, 11, 28, 15)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Collar
    final collar = Path()
      ..moveTo(43, 20)
      ..lineTo(43, 30)
      ..lineTo(57, 30)
      ..lineTo(57, 20);
    canvas.drawPath(collar, stroke);

    // Half zip (goes to mid-chest)
    canvas.drawLine(const Offset(50, 30), const Offset(50, 66), stroke);
    canvas.drawCircle(const Offset(50, 66), 2.5, fill);
    canvas.drawCircle(const Offset(50, 66), 2.5, stroke);
  }

  // ── Jacket ───────────────────────────────────────────────────────────────
  void _drawJacket(Canvas canvas, Paint fill, Paint stroke) {
    // Body
    final body = Path()
      ..moveTo(22, 28)
      ..lineTo(5, 22)
      ..lineTo(2, 52)
      ..lineTo(18, 56)
      ..lineTo(18, 97)
      ..lineTo(82, 97)
      ..lineTo(82, 56)
      ..lineTo(98, 52)
      ..lineTo(95, 22)
      ..lineTo(78, 28)
      ..lineTo(72, 14)
      ..lineTo(60, 20)
      ..lineTo(50, 22)
      ..lineTo(40, 20)
      ..lineTo(28, 14)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Collar / lapels
    final leftLapel = Path()
      ..moveTo(40, 20)
      ..lineTo(36, 32)
      ..lineTo(44, 40)
      ..lineTo(50, 36)
      ..lineTo(50, 22)
      ..close();
    final rightLapel = Path()
      ..moveTo(60, 20)
      ..lineTo(64, 32)
      ..lineTo(56, 40)
      ..lineTo(50, 36)
      ..lineTo(50, 22)
      ..close();
    canvas.drawPath(leftLapel, stroke);
    canvas.drawPath(rightLapel, stroke);

    // Center zip/button line
    canvas.drawLine(const Offset(50, 40), const Offset(50, 97), stroke);

    // Pockets
    final lPocket = RRect.fromRectAndRadius(
        const Rect.fromLTWH(22, 65, 18, 12), const Radius.circular(2));
    final rPocket = RRect.fromRectAndRadius(
        const Rect.fromLTWH(60, 65, 18, 12), const Radius.circular(2));
    canvas.drawRRect(lPocket, stroke);
    canvas.drawRRect(rPocket, stroke);
  }

  // ── Pants / Jogger ───────────────────────────────────────────────────────
  void _drawPants(Canvas canvas, Paint fill, Paint stroke) {
    final pants = Path()
      ..moveTo(20, 5)
      ..lineTo(80, 5)
      ..lineTo(82, 30)
      ..lineTo(60, 35)
      ..lineTo(58, 95)
      ..lineTo(42, 95)
      ..lineTo(40, 35)
      ..lineTo(18, 30)
      ..close();
    canvas.drawPath(pants, fill);
    canvas.drawPath(pants, stroke);

    // Waistband
    canvas.drawLine(const Offset(20, 5), const Offset(80, 5),
        stroke..strokeWidth = stroke.strokeWidth * 2);
    canvas.drawLine(const Offset(20, 14), const Offset(80, 14), stroke);
    // Drawstring
    canvas.drawLine(const Offset(44, 5), const Offset(42, 14), stroke);
    canvas.drawLine(const Offset(56, 5), const Offset(58, 14), stroke);
    // Center seam
    canvas.drawLine(const Offset(50, 35), const Offset(50, 14), stroke);
    // Cuffs (jogger style)
    canvas.drawLine(const Offset(42, 88), const Offset(58, 88), stroke);
    canvas.drawLine(const Offset(40, 95), const Offset(56, 95), stroke);
  }

  // ── Shorts ───────────────────────────────────────────────────────────────
  void _drawShorts(Canvas canvas, Paint fill, Paint stroke) {
    final shorts = Path()
      ..moveTo(18, 5)
      ..lineTo(82, 5)
      ..lineTo(84, 25)
      ..lineTo(62, 28)
      ..lineTo(60, 60)
      ..lineTo(40, 60)
      ..lineTo(38, 28)
      ..lineTo(16, 25)
      ..close();
    canvas.drawPath(shorts, fill);
    canvas.drawPath(shorts, stroke);

    // Waistband
    canvas.drawLine(const Offset(18, 5), const Offset(82, 5),
        stroke..strokeWidth = stroke.strokeWidth * 2);
    canvas.drawLine(const Offset(18, 15), const Offset(82, 15), stroke);
    // Drawstring
    canvas.drawLine(const Offset(44, 5), const Offset(43, 15), stroke);
    canvas.drawLine(const Offset(56, 5), const Offset(57, 15), stroke);
    // Center seam
    canvas.drawLine(const Offset(50, 28), const Offset(50, 15), stroke);
  }

  // ── Vest ─────────────────────────────────────────────────────────────────
  void _drawVest(Canvas canvas, Paint fill, Paint stroke) {
    final vest = Path()
      ..moveTo(28, 20)
      ..lineTo(10, 25)
      ..lineTo(12, 60)
      ..lineTo(26, 58)
      ..lineTo(26, 97)
      ..lineTo(74, 97)
      ..lineTo(74, 58)
      ..lineTo(88, 60)
      ..lineTo(90, 25)
      ..lineTo(72, 20)
      ..lineTo(65, 12)
      ..lineTo(58, 16)
      ..lineTo(50, 18)
      ..lineTo(42, 16)
      ..lineTo(35, 12)
      ..close();
    canvas.drawPath(vest, fill);
    canvas.drawPath(vest, stroke);

    // Armhole curves
    final lArm = Path()
      ..moveTo(28, 20)
      ..quadraticBezierTo(16, 35, 26, 58);
    final rArm = Path()
      ..moveTo(72, 20)
      ..quadraticBezierTo(84, 35, 74, 58);
    canvas.drawPath(lArm, stroke);
    canvas.drawPath(rArm, stroke);

    // Collar + zip
    canvas.drawLine(const Offset(42, 16), const Offset(40, 30), stroke);
    canvas.drawLine(const Offset(58, 16), const Offset(60, 30), stroke);
    canvas.drawLine(const Offset(40, 30), const Offset(60, 30), stroke);
    canvas.drawLine(const Offset(50, 30), const Offset(50, 97), stroke);
  }

  // ── Hat ──────────────────────────────────────────────────────────────────
  void _drawHat(Canvas canvas, Paint fill, Paint stroke) {
    // Crown
    final crown = Path()
      ..moveTo(15, 58)
      ..quadraticBezierTo(20, 20, 50, 15)
      ..quadraticBezierTo(80, 20, 85, 58)
      ..close();
    canvas.drawPath(crown, fill);
    canvas.drawPath(crown, stroke);

    // Brim
    final brim = Path()
      ..moveTo(10, 62)
      ..lineTo(72, 62)
      ..lineTo(68, 72)
      ..lineTo(10, 72)
      ..close();
    canvas.drawPath(brim, fill);
    canvas.drawPath(brim, stroke);

    // Band
    canvas.drawLine(const Offset(15, 58), const Offset(85, 58), stroke);

    // Button on top
    canvas.drawCircle(const Offset(50, 17), 3, fill);
    canvas.drawCircle(const Offset(50, 17), 3, stroke);
  }

  // ── Shoes ────────────────────────────────────────────────────────────────
  void _drawShoes(Canvas canvas, Paint fill, Paint stroke) {
    // Left shoe
    final left = Path()
      ..moveTo(5, 70)
      ..lineTo(5, 52)
      ..lineTo(25, 45)
      ..lineTo(42, 45)
      ..lineTo(42, 65)
      ..quadraticBezierTo(35, 72, 20, 72)
      ..quadraticBezierTo(8, 72, 5, 70)
      ..close();
    canvas.drawPath(left, fill);
    canvas.drawPath(left, stroke);
    // Sole
    canvas.drawLine(const Offset(5, 70), const Offset(42, 68), stroke);

    // Right shoe
    final right = Path()
      ..moveTo(58, 70)
      ..lineTo(58, 52)
      ..lineTo(75, 45)
      ..lineTo(95, 45)
      ..lineTo(95, 70)
      ..quadraticBezierTo(88, 72, 75, 72)
      ..quadraticBezierTo(62, 72, 58, 70)
      ..close();
    canvas.drawPath(right, fill);
    canvas.drawPath(right, stroke);
    canvas.drawLine(const Offset(58, 70), const Offset(95, 68), stroke);
  }

  // ── Accessory (generic bag/item) ─────────────────────────────────────────
  void _drawAccessory(Canvas canvas, Paint fill, Paint stroke) {
    final bag = RRect.fromRectAndRadius(
      const Rect.fromLTWH(20, 30, 60, 65),
      const Radius.circular(6),
    );
    canvas.drawRRect(bag, fill);
    canvas.drawRRect(bag, stroke);

    // Handle
    final handle = Path()
      ..moveTo(35, 30)
      ..quadraticBezierTo(35, 18, 50, 18)
      ..quadraticBezierTo(65, 18, 65, 30);
    canvas.drawPath(handle, stroke);

    // Pocket
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(30, 55, 40, 28), const Radius.circular(4)),
      stroke,
    );
  }

  @override
  bool shouldRepaint(GarmentPainter old) =>
      old.type != type ||
      old.fillColor != fillColor ||
      old.strokeColor != strokeColor;
}

/// A ready-to-use widget that renders a garment illustration.
class GarmentIllustration extends StatelessWidget {
  final GarmentType type;
  final Color color;
  final double width;
  final double height;

  const GarmentIllustration({
    super.key,
    required this.type,
    required this.color,
    this.width = 80,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: GarmentPainter(
        type: type,
        fillColor: color,
        strokeColor: _strokeFor(color),
      ),
    );
  }

  Color _strokeFor(Color fill) {
    final luminance = fill.computeLuminance();
    return luminance > 0.85
        ? const Color(0xFF555555)
        : luminance < 0.15
            ? const Color(0xFF444444)
            : const Color(0xFF333333);
  }
}
