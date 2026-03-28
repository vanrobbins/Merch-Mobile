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
      case GarmentType.sneaker:
        _drawSneaker(canvas, fill, stroke);
      case GarmentType.runningShoe:
        _drawRunningShoe(canvas, fill, stroke);
      case GarmentType.boot:
        _drawBoot(canvas, fill, stroke);
      case GarmentType.sandal:
        _drawSandal(canvas, fill, stroke);
      case GarmentType.bra:
        _drawBra(canvas, fill, stroke);
      case GarmentType.tankTop:
        _drawTankTop(canvas, fill, stroke);
      case GarmentType.cropTop:
        _drawCropTop(canvas, fill, stroke);
      case GarmentType.longSleeveCropTop:
        _drawLongSleeveCropTop(canvas, fill, stroke);
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

  // ── Sneaker (low-top athletic) ────────────────────────────────────────────
  void _drawSneaker(Canvas canvas, Paint fill, Paint stroke) {
    // Left sneaker (side profile)
    final lSole = Path()
      ..moveTo(2, 72)
      ..lineTo(2, 66)
      ..quadraticBezierTo(4, 60, 12, 57)
      ..lineTo(12, 48)
      ..quadraticBezierTo(14, 42, 22, 40)
      ..lineTo(38, 40)
      ..quadraticBezierTo(44, 40, 44, 46)
      ..lineTo(44, 65)
      ..quadraticBezierTo(40, 72, 30, 74)
      ..quadraticBezierTo(12, 76, 2, 72)
      ..close();
    canvas.drawPath(lSole, fill);
    canvas.drawPath(lSole, stroke);
    // Midsole stripe
    final lMidsole = Paint()
      ..color = const Color(0xFFFFFFFF).withAlpha(80)
      ..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()
        ..moveTo(2, 68)
        ..lineTo(44, 66)
        ..lineTo(44, 70)
        ..quadraticBezierTo(30, 76, 2, 72)
        ..close(),
      lMidsole,
    );
    // Laces
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(18.0 + i * 7, 41.0),
        Offset(17.0 + i * 7, 50.0),
        stroke..strokeWidth = stroke.strokeWidth * 0.7,
      );
    }
    // Tongue tab
    canvas.drawLine(const Offset(22, 40), const Offset(22, 44), stroke);

    // Right sneaker
    final rSole = Path()
      ..moveTo(56, 72)
      ..lineTo(56, 66)
      ..quadraticBezierTo(58, 60, 66, 57)
      ..lineTo(66, 48)
      ..quadraticBezierTo(68, 42, 76, 40)
      ..lineTo(92, 40)
      ..quadraticBezierTo(98, 40, 98, 46)
      ..lineTo(98, 65)
      ..quadraticBezierTo(94, 72, 84, 74)
      ..quadraticBezierTo(66, 76, 56, 72)
      ..close();
    canvas.drawPath(rSole, fill);
    canvas.drawPath(rSole, stroke);
    canvas.drawPath(
      Path()
        ..moveTo(56, 68)
        ..lineTo(98, 66)
        ..lineTo(98, 70)
        ..quadraticBezierTo(84, 76, 56, 72)
        ..close(),
      lMidsole,
    );
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(72.0 + i * 7, 41.0),
        Offset(71.0 + i * 7, 50.0),
        stroke..strokeWidth = stroke.strokeWidth * 0.7,
      );
    }
  }

  // ── Running Shoe (lightweight, mesh upper) ────────────────────────────────
  void _drawRunningShoe(Canvas canvas, Paint fill, Paint stroke) {
    // Left – more aggressive heel/toe profile
    final accentFill = Paint()
      ..color = fill.color.withAlpha(200)
      ..style = PaintingStyle.fill;

    final lUpper = Path()
      ..moveTo(4, 65)
      ..lineTo(4, 55)
      ..quadraticBezierTo(6, 44, 16, 40)
      ..lineTo(16, 32)
      ..quadraticBezierTo(18, 26, 28, 25)
      ..lineTo(38, 25)
      ..quadraticBezierTo(46, 25, 46, 32)
      ..lineTo(46, 58)
      ..quadraticBezierTo(42, 68, 28, 70)
      ..quadraticBezierTo(10, 72, 4, 65)
      ..close();
    canvas.drawPath(lUpper, fill);

    // Heel cup reinforcement
    final lHeel = Path()
      ..moveTo(4, 65)
      ..lineTo(4, 48)
      ..lineTo(12, 46)
      ..lineTo(12, 64)
      ..close();
    canvas.drawPath(lHeel, accentFill);
    canvas.drawPath(lHeel, stroke);
    canvas.drawPath(lUpper, stroke);

    // Chunky midsole
    final lMid = Path()
      ..moveTo(2, 68)
      ..lineTo(48, 65)
      ..lineTo(48, 73)
      ..quadraticBezierTo(35, 78, 10, 76)
      ..quadraticBezierTo(2, 74, 2, 68)
      ..close();
    final midFill = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.fill;
    canvas.drawPath(lMid, midFill);
    canvas.drawPath(lMid, stroke);

    // Right shoe (mirror)
    final rUpper = Path()
      ..moveTo(54, 65)
      ..lineTo(54, 55)
      ..quadraticBezierTo(56, 44, 66, 40)
      ..lineTo(66, 32)
      ..quadraticBezierTo(68, 26, 78, 25)
      ..lineTo(88, 25)
      ..quadraticBezierTo(96, 25, 96, 32)
      ..lineTo(96, 58)
      ..quadraticBezierTo(92, 68, 78, 70)
      ..quadraticBezierTo(60, 72, 54, 65)
      ..close();
    canvas.drawPath(rUpper, fill);
    final rHeel = Path()
      ..moveTo(54, 65)
      ..lineTo(54, 48)
      ..lineTo(62, 46)
      ..lineTo(62, 64)
      ..close();
    canvas.drawPath(rHeel, accentFill);
    canvas.drawPath(rHeel, stroke);
    canvas.drawPath(rUpper, stroke);
    final rMid = Path()
      ..moveTo(52, 68)
      ..lineTo(98, 65)
      ..lineTo(98, 73)
      ..quadraticBezierTo(85, 78, 60, 76)
      ..quadraticBezierTo(52, 74, 52, 68)
      ..close();
    canvas.drawPath(rMid, midFill);
    canvas.drawPath(rMid, stroke);
  }

  // ── Boot (ankle/mid-calf height) ──────────────────────────────────────────
  void _drawBoot(Canvas canvas, Paint fill, Paint stroke) {
    // Left boot
    final lBoot = Path()
      ..moveTo(12, 5)     // top of shaft
      ..lineTo(30, 5)
      ..lineTo(32, 55)    // shaft down to ankle
      ..quadraticBezierTo(36, 58, 42, 58)
      ..lineTo(44, 65)
      ..quadraticBezierTo(44, 72, 36, 74)
      ..lineTo(8, 74)
      ..quadraticBezierTo(2, 72, 2, 65)
      ..lineTo(2, 58)
      ..quadraticBezierTo(8, 55, 10, 48)
      ..lineTo(10, 5)
      ..close();
    canvas.drawPath(lBoot, fill);
    canvas.drawPath(lBoot, stroke);
    // Sole
    canvas.drawPath(
      Path()
        ..moveTo(2, 68)
        ..lineTo(44, 68)
        ..lineTo(44, 74)
        ..lineTo(2, 74)
        ..close(),
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.fill,
    );
    canvas.drawLine(const Offset(2, 68), const Offset(44, 68), stroke);
    // Shaft crease
    canvas.drawLine(const Offset(11, 5), const Offset(11, 48), stroke);
    // Zipper hint (right side)
    canvas.drawLine(const Offset(29, 8), const Offset(31, 48), stroke);

    // Right boot
    final rBoot = Path()
      ..moveTo(62, 5)
      ..lineTo(80, 5)
      ..lineTo(82, 55)
      ..quadraticBezierTo(86, 58, 92, 58)
      ..lineTo(94, 65)
      ..quadraticBezierTo(94, 72, 86, 74)
      ..lineTo(58, 74)
      ..quadraticBezierTo(52, 72, 52, 65)
      ..lineTo(52, 58)
      ..quadraticBezierTo(58, 55, 60, 48)
      ..lineTo(60, 5)
      ..close();
    canvas.drawPath(rBoot, fill);
    canvas.drawPath(rBoot, stroke);
    canvas.drawPath(
      Path()
        ..moveTo(52, 68)
        ..lineTo(94, 68)
        ..lineTo(94, 74)
        ..lineTo(52, 74)
        ..close(),
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.fill,
    );
    canvas.drawLine(const Offset(52, 68), const Offset(94, 68), stroke);
    canvas.drawLine(const Offset(61, 5), const Offset(61, 48), stroke);
    canvas.drawLine(const Offset(79, 8), const Offset(81, 48), stroke);
  }

  // ── Sandal / Slide ────────────────────────────────────────────────────────
  void _drawSandal(Canvas canvas, Paint fill, Paint stroke) {
    // Left sandal – thin footbed + two straps
    final lSole = Path()
      ..moveTo(2, 70)
      ..quadraticBezierTo(6, 60, 14, 56)
      ..lineTo(40, 56)
      ..quadraticBezierTo(46, 56, 46, 62)
      ..lineTo(46, 70)
      ..quadraticBezierTo(40, 76, 24, 76)
      ..quadraticBezierTo(6, 76, 2, 70)
      ..close();
    canvas.drawPath(lSole, fill);
    canvas.drawPath(lSole, stroke);

    // Straps
    final strapFill = Paint()
      ..color = fill.color
      ..style = PaintingStyle.fill;
    // Front strap
    canvas.drawPath(
      Path()
        ..moveTo(20, 56)
        ..lineTo(20, 50)
        ..lineTo(32, 50)
        ..lineTo(32, 56)
        ..close(),
      strapFill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(20, 56)
        ..lineTo(20, 50)
        ..lineTo(32, 50)
        ..lineTo(32, 56)
        ..close(),
      stroke,
    );
    // Ankle strap
    canvas.drawPath(
      Path()
        ..moveTo(10, 60)
        ..lineTo(10, 54)
        ..quadraticBezierTo(16, 50, 24, 50)
        ..quadraticBezierTo(32, 50, 38, 54)
        ..lineTo(38, 60),
      stroke,
    );
    // Footbed texture
    final thinStroke = Paint()
      ..color = stroke.color.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(6.0 + i * 12, 66.0),
        Offset(10.0 + i * 12, 66.0),
        thinStroke,
      );
    }

    // Right sandal (offset right)
    final rSole = Path()
      ..moveTo(54, 70)
      ..quadraticBezierTo(58, 60, 66, 56)
      ..lineTo(92, 56)
      ..quadraticBezierTo(98, 56, 98, 62)
      ..lineTo(98, 70)
      ..quadraticBezierTo(92, 76, 76, 76)
      ..quadraticBezierTo(58, 76, 54, 70)
      ..close();
    canvas.drawPath(rSole, fill);
    canvas.drawPath(rSole, stroke);
    canvas.drawPath(
      Path()
        ..moveTo(72, 56)
        ..lineTo(72, 50)
        ..lineTo(84, 50)
        ..lineTo(84, 56)
        ..close(),
      strapFill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(72, 56)
        ..lineTo(72, 50)
        ..lineTo(84, 50)
        ..lineTo(84, 56)
        ..close(),
      stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(62, 60)
        ..lineTo(62, 54)
        ..quadraticBezierTo(68, 50, 76, 50)
        ..quadraticBezierTo(84, 50, 90, 54)
        ..lineTo(90, 60),
      stroke,
    );
  }

  // ── Bra / Sports Bra ──────────────────────────────────────────────────────
  void _drawBra(Canvas canvas, Paint fill, Paint stroke) {
    // Left cup
    final lCup = Path()
      ..moveTo(50, 55)
      ..quadraticBezierTo(38, 50, 22, 55)
      ..quadraticBezierTo(12, 60, 14, 72)
      ..quadraticBezierTo(20, 80, 30, 80)
      ..quadraticBezierTo(44, 80, 50, 70)
      ..close();
    canvas.drawPath(lCup, fill);
    canvas.drawPath(lCup, stroke);

    // Right cup
    final rCup = Path()
      ..moveTo(50, 55)
      ..quadraticBezierTo(62, 50, 78, 55)
      ..quadraticBezierTo(88, 60, 86, 72)
      ..quadraticBezierTo(80, 80, 70, 80)
      ..quadraticBezierTo(56, 80, 50, 70)
      ..close();
    canvas.drawPath(rCup, fill);
    canvas.drawPath(rCup, stroke);

    // Center gore
    canvas.drawLine(const Offset(50, 55), const Offset(50, 72), stroke);

    // Band / underband
    final band = Path()
      ..moveTo(14, 72)
      ..lineTo(86, 72)
      ..lineTo(86, 80)
      ..lineTo(14, 80)
      ..close();
    canvas.drawPath(band, fill);
    canvas.drawPath(band, stroke);

    // Clasp on band (back)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(44, 73, 12, 6), const Radius.circular(2)),
      stroke,
    );

    // Left shoulder strap
    final lStrap = Path()
      ..moveTo(26, 55)
      ..quadraticBezierTo(24, 35, 30, 18)
      ..lineTo(38, 22)
      ..quadraticBezierTo(34, 36, 36, 55);
    canvas.drawPath(lStrap, fill);
    canvas.drawPath(lStrap, stroke);

    // Right shoulder strap
    final rStrap = Path()
      ..moveTo(74, 55)
      ..quadraticBezierTo(76, 35, 70, 18)
      ..lineTo(62, 22)
      ..quadraticBezierTo(66, 36, 64, 55);
    canvas.drawPath(rStrap, fill);
    canvas.drawPath(rStrap, stroke);

    // Sports-bra style front seam detail
    canvas.drawPath(
      Path()
        ..moveTo(36, 55)
        ..quadraticBezierTo(44, 62, 50, 62)
        ..quadraticBezierTo(56, 62, 64, 55),
      stroke..strokeWidth = stroke.strokeWidth * 0.8,
    );
  }

  // ── Tank Top ─────────────────────────────────────────────────────────────
  // Sleeveless; wide scoop or straight neckline; narrow shoulder straps.
  void _drawTankTop(Canvas canvas, Paint fill, Paint stroke) {
    // Body
    final body = Path()
      ..moveTo(30, 18)       // left strap base
      ..lineTo(20, 18)       // left armhole outer
      ..quadraticBezierTo(10, 22, 12, 38) // armhole curve
      ..lineTo(15, 95)
      ..lineTo(85, 95)
      ..lineTo(88, 38)
      ..quadraticBezierTo(90, 22, 80, 18) // right armhole curve
      ..lineTo(70, 18)       // right strap base
      // Scoop neck: right strap → neckline → left strap
      ..quadraticBezierTo(65, 8, 50, 10)
      ..quadraticBezierTo(35, 8, 30, 18)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Neckline stitch detail
    final neckDetail = Path()
      ..moveTo(32, 20)
      ..quadraticBezierTo(50, 13, 68, 20);
    canvas.drawPath(neckDetail,
        Paint()
          ..color = stroke.color.withAlpha(80)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7);

    // Side seams
    canvas.drawLine(const Offset(20, 38), const Offset(18, 90), stroke..strokeWidth = 0.6);
    canvas.drawLine(const Offset(80, 38), const Offset(82, 90), stroke..strokeWidth = 0.6);
    stroke.strokeWidth = 1.0;
  }

  // ── Crop Top ──────────────────────────────────────────────────────────────
  // Short body ending above the navel; short sleeves; fitted silhouette.
  void _drawCropTop(Canvas canvas, Paint fill, Paint stroke) {
    // Body — ends around y=62 (cropped)
    final body = Path()
      ..moveTo(28, 26)       // neck-shoulder junction
      ..lineTo(14, 22)       // left shoulder
      ..lineTo(8, 30)        // left sleeve outer
      ..lineTo(15, 44)       // left underarm
      ..lineTo(16, 64)       // left hem
      ..lineTo(84, 64)       // right hem
      ..lineTo(85, 44)       // right underarm
      ..lineTo(92, 30)       // right sleeve outer
      ..lineTo(86, 22)       // right shoulder
      ..lineTo(72, 26)       // neck-shoulder junction
      // Crew neck
      ..quadraticBezierTo(62, 18, 50, 19)
      ..quadraticBezierTo(38, 18, 28, 26)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Crop hem detail line
    canvas.drawLine(const Offset(16, 64), const Offset(84, 64), stroke);

    // Center seam hint
    canvas.drawLine(const Offset(50, 28), const Offset(50, 62),
        Paint()
          ..color = stroke.color.withAlpha(40)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6);
  }

  // ── Long Sleeve Crop Top ──────────────────────────────────────────────────
  // Fitted; full-length sleeves; body cropped above navel; ribbed cuffs.
  void _drawLongSleeveCropTop(Canvas canvas, Paint fill, Paint stroke) {
    // Body — cropped at ~y=65
    final body = Path()
      ..moveTo(30, 24)
      ..lineTo(70, 24)
      ..lineTo(72, 65)
      ..lineTo(28, 65)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Left sleeve — long, tapered
    final lSleeve = Path()
      ..moveTo(30, 24)
      ..lineTo(14, 20)
      ..lineTo(5, 72)      // cuff outer
      ..lineTo(14, 74)     // cuff inner
      ..lineTo(22, 34)     // underarm merge
      ..lineTo(28, 30)
      ..close();
    canvas.drawPath(lSleeve, fill);
    canvas.drawPath(lSleeve, stroke);

    // Right sleeve — long, tapered
    final rSleeve = Path()
      ..moveTo(70, 24)
      ..lineTo(86, 20)
      ..lineTo(95, 72)
      ..lineTo(86, 74)
      ..lineTo(78, 34)
      ..lineTo(72, 30)
      ..close();
    canvas.drawPath(rSleeve, fill);
    canvas.drawPath(rSleeve, stroke);

    // Crew neck
    final neck = Path()
      ..moveTo(30, 24)
      ..quadraticBezierTo(50, 14, 70, 24);
    canvas.drawPath(neck, stroke);

    // Ribbed cuffs — 3 horizontal lines at wrist
    final cuffPaint = Paint()
      ..color = stroke.color.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (int i = 0; i < 3; i++) {
      final t = i / 3.0;
      // Left cuff area (approx)
      canvas.drawLine(
          Offset(5 + t * 2, 72 - t * 2), Offset(14 + t * 2, 74 - t * 2),
          cuffPaint);
      // Right cuff area
      canvas.drawLine(
          Offset(95 - t * 2, 72 - t * 2), Offset(86 - t * 2, 74 - t * 2),
          cuffPaint);
    }

    // Hem line
    canvas.drawLine(const Offset(28, 65), const Offset(72, 65), stroke);
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

// ── Folded Garment Painter ────────────────────────────────────────────────────

/// Draws a top-down view of a folded garment as it appears stacked on a shelf.
/// Shows the front face of the fold with fold crease and type-specific top detail.
class FoldedGarmentPainter extends CustomPainter {
  final GarmentType type;
  final Color fillColor;

  const FoldedGarmentPainter({
    required this.type,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokeColor = fillColor.computeLuminance() > 0.7
        ? const Color(0xFF888888)
        : const Color(0xFF333333);

    final fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeJoin = StrokeJoin.round;
    final creasePaint = Paint()
      ..color = strokeColor.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final detailPaint = Paint()
      ..color = strokeColor.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    // Main folded rectangle with slight rounded corners
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, w - 2, h - 2),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, stroke);

    // Horizontal fold crease at mid-height
    final creaseY = h * 0.52;
    canvas.drawLine(
      Offset(4, creaseY),
      Offset(w - 4, creaseY),
      creasePaint,
    );

    // Type-specific top detail
    _drawTopDetail(canvas, w, h, detailPaint, strokeColor);

    // Shadow gradient on bottom half to suggest depth
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, strokeColor.withAlpha(18)],
      ).createShader(Rect.fromLTWH(0, creaseY, w, h - creaseY));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, creaseY, w - 2, h - creaseY - 1),
        const Radius.circular(3),
      ),
      shadowPaint,
    );
  }

  void _drawTopDetail(
      Canvas canvas, double w, double h, Paint detail, Color strokeColor) {
    final topY = h * 0.12;
    switch (type) {
      case GarmentType.tshirt:
      case GarmentType.hoodie:
      case GarmentType.vest:
      case GarmentType.halfZip:
      case GarmentType.quarterZip:
      case GarmentType.jacket:
      case GarmentType.cropTop:
      case GarmentType.longSleeveCropTop:
        // Collar/neck hint: small U-curve at top center
        final neckPath = Path()
          ..moveTo(w * 0.38, topY + 2)
          ..quadraticBezierTo(w * 0.5, topY + h * 0.08, w * 0.62, topY + 2);
        canvas.drawPath(neckPath, detail);
        break;
      case GarmentType.tankTop:
        // Deep scoop neck hint
        final scoopPath = Path()
          ..moveTo(w * 0.32, topY + 1)
          ..quadraticBezierTo(w * 0.5, topY + h * 0.12, w * 0.68, topY + 1);
        canvas.drawPath(scoopPath, detail);
        break;
      case GarmentType.jogger:
      case GarmentType.pants:
        // Waistband: double horizontal line at top
        canvas.drawLine(Offset(4, topY), Offset(w - 4, topY), detail);
        canvas.drawLine(
            Offset(4, topY + 3), Offset(w - 4, topY + 3), detail);
        // Center seam
        canvas.drawLine(
            Offset(w * 0.5, topY + 5), Offset(w * 0.5, h * 0.45), detail);
        break;
      case GarmentType.shorts:
        canvas.drawLine(Offset(4, topY), Offset(w - 4, topY), detail);
        canvas.drawLine(
            Offset(4, topY + 3), Offset(w - 4, topY + 3), detail);
        canvas.drawLine(
            Offset(w * 0.5, topY + 5), Offset(w * 0.5, h * 0.38), detail);
        break;
      case GarmentType.hat:
        // Brim line
        canvas.drawLine(
            Offset(w * 0.15, topY + 6), Offset(w * 0.85, topY + 6), detail);
        break;
      case GarmentType.bra:
        // Two cup outlines
        final leftCup = Path()
          ..addOval(
              Rect.fromCenter(center: Offset(w * 0.32, topY + 6), width: w * 0.28, height: h * 0.14));
        final rightCup = Path()
          ..addOval(
              Rect.fromCenter(center: Offset(w * 0.68, topY + 6), width: w * 0.28, height: h * 0.14));
        canvas.drawPath(leftCup, detail);
        canvas.drawPath(rightCup, detail);
        break;
      default:
        // Generic: just a small centered dot/label area
        break;
    }
  }

  @override
  bool shouldRepaint(FoldedGarmentPainter old) =>
      old.type != type || old.fillColor != fillColor;
}

/// A folded garment shown as it would appear stacked on a shelf (top-down view).
class FoldedGarmentWidget extends StatelessWidget {
  final GarmentType type;
  final Color color;
  final double width;
  final double height;

  const FoldedGarmentWidget({
    super.key,
    required this.type,
    required this.color,
    this.width = 56,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: FoldedGarmentPainter(type: type, fillColor: color),
    );
  }
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
