import 'package:flutter/material.dart';

// ── Half Mannequin Painter ────────────────────────────────────────────────────

/// Torso-only (head to waist) mannequin form used for displaying tops on shelves.
/// Includes a small pedestal base so it sits flat on a shelf.
class HalfMannequinPainter extends CustomPainter {
  final Color bodyColor;
  final Color outfitTopColor;

  const HalfMannequinPainter({
    this.bodyColor = const Color(0xFFE8D5C4),
    this.outfitTopColor = const Color(0xFF90B8CC),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 100;
    canvas.save();
    canvas.scale(sx, sy);

    final body = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;
    final top = Paint()
      ..color = outfitTopColor
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeJoin = StrokeJoin.round;
    final pedestalFill = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.fill;

    // ── Head ────────────────────────────────────────────────────────────────
    canvas.drawOval(const Rect.fromLTWH(32, 2, 36, 22), body);
    canvas.drawOval(const Rect.fromLTWH(32, 2, 36, 22), stroke);

    // ── Neck ────────────────────────────────────────────────────────────────
    final neck = Path()
      ..moveTo(43, 22)
      ..lineTo(43, 28)
      ..lineTo(57, 28)
      ..lineTo(57, 22)
      ..close();
    canvas.drawPath(neck, body);

    // ── Torso (outfit top color) ─────────────────────────────────────────────
    final torso = Path()
      ..moveTo(22, 28)
      ..quadraticBezierTo(20, 36, 20, 44)
      ..lineTo(20, 68)
      ..lineTo(80, 68)
      ..lineTo(80, 44)
      ..quadraticBezierTo(80, 36, 78, 28)
      ..close();
    canvas.drawPath(torso, top);
    canvas.drawPath(torso, stroke);

    // ── Left arm ────────────────────────────────────────────────────────────
    final lArm = Path()
      ..moveTo(22, 28)
      ..lineTo(8, 32)
      ..quadraticBezierTo(4, 42, 6, 54)
      ..lineTo(14, 54)
      ..quadraticBezierTo(14, 44, 20, 40)
      ..lineTo(24, 34)
      ..close();
    canvas.drawPath(lArm, top);
    canvas.drawPath(lArm, stroke);

    // ── Right arm ───────────────────────────────────────────────────────────
    final rArm = Path()
      ..moveTo(78, 28)
      ..lineTo(92, 32)
      ..quadraticBezierTo(96, 42, 94, 54)
      ..lineTo(86, 54)
      ..quadraticBezierTo(86, 44, 80, 40)
      ..lineTo(76, 34)
      ..close();
    canvas.drawPath(rArm, top);
    canvas.drawPath(rArm, stroke);

    // ── Waist cutoff line ────────────────────────────────────────────────────
    canvas.drawLine(
      const Offset(20, 68),
      const Offset(80, 68),
      Paint()
        ..color = const Color(0xFF777777)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // ── Neck collar hint ────────────────────────────────────────────────────
    final collar = Path()
      ..moveTo(40, 28)
      ..quadraticBezierTo(50, 36, 60, 28);
    canvas.drawPath(
        collar,
        Paint()
          ..color = const Color(0xFF888888)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);

    // ── Pedestal ────────────────────────────────────────────────────────────
    final pedestalTop = RRect.fromRectAndRadius(
      const Rect.fromLTWH(34, 68, 32, 6),
      const Radius.circular(2),
    );
    final pedestalBase = RRect.fromRectAndRadius(
      const Rect.fromLTWH(26, 74, 48, 8),
      const Radius.circular(3),
    );
    canvas.drawRRect(pedestalTop, pedestalFill);
    canvas.drawRRect(pedestalBase, pedestalFill);
    canvas.drawRRect(pedestalTop, stroke);
    canvas.drawRRect(pedestalBase, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(HalfMannequinPainter old) =>
      old.bodyColor != bodyColor || old.outfitTopColor != outfitTopColor;
}

class HalfMannequinFigure extends StatelessWidget {
  final Color topColor;
  final double width;
  final double height;

  const HalfMannequinFigure({
    super.key,
    required this.topColor,
    this.width = 56,
    this.height = 96,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: HalfMannequinPainter(outfitTopColor: topColor),
    );
  }
}

// ── Bra Form Painter ──────────────────────────────────────────────────────────

/// A headless, armless bust form used for displaying bras on shelves.
/// Renders the chest/bust silhouette with a bra outline and pedestal.
class BraMannequinPainter extends CustomPainter {
  final Color bodyColor;
  final Color braColor;

  const BraMannequinPainter({
    this.bodyColor = const Color(0xFFE8D5C4),
    this.braColor = const Color(0xFF90B8CC),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 100;
    canvas.save();
    canvas.scale(sx, sy);

    final body = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;
    final bra = Paint()
      ..color = braColor
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeJoin = StrokeJoin.round;
    final pedestalFill = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.fill;
    final detail = Paint()
      ..color = const Color(0xFF666666)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    // ── Bust form body ──────────────────────────────────────────────────────
    final bustForm = Path()
      ..moveTo(28, 6)
      ..quadraticBezierTo(20, 8, 16, 18)
      ..quadraticBezierTo(10, 32, 12, 48)
      ..lineTo(12, 62)
      ..lineTo(88, 62)
      ..lineTo(88, 48)
      ..quadraticBezierTo(90, 32, 84, 18)
      ..quadraticBezierTo(80, 8, 72, 6)
      ..close();
    canvas.drawPath(bustForm, body);
    canvas.drawPath(bustForm, stroke);

    // ── Bra cups (left) ──────────────────────────────────────────────────────
    final leftCup = Path()
      ..moveTo(16, 22)
      ..quadraticBezierTo(14, 30, 16, 40)
      ..quadraticBezierTo(26, 46, 46, 42)
      ..lineTo(46, 22)
      ..close();
    canvas.drawPath(leftCup, bra);
    canvas.drawPath(leftCup, stroke);

    // ── Bra cups (right) ─────────────────────────────────────────────────────
    final rightCup = Path()
      ..moveTo(84, 22)
      ..quadraticBezierTo(86, 30, 84, 40)
      ..quadraticBezierTo(74, 46, 54, 42)
      ..lineTo(54, 22)
      ..close();
    canvas.drawPath(rightCup, bra);
    canvas.drawPath(rightCup, stroke);

    // ── Center gore ─────────────────────────────────────────────────────────
    final gore = Path()
      ..moveTo(46, 22)
      ..lineTo(54, 22)
      ..lineTo(54, 42)
      ..quadraticBezierTo(50, 46, 46, 42)
      ..close();
    canvas.drawPath(gore, bra);
    canvas.drawPath(gore, stroke);

    // ── Underband ────────────────────────────────────────────────────────────
    final band = Path()
      ..moveTo(16, 40)
      ..lineTo(84, 40)
      ..lineTo(84, 46)
      ..lineTo(16, 46)
      ..close();
    canvas.drawPath(band, bra);
    canvas.drawPath(band, stroke);

    // ── Shoulder straps ──────────────────────────────────────────────────────
    canvas.drawLine(const Offset(26, 6), const Offset(22, 22), detail);
    canvas.drawLine(const Offset(74, 6), const Offset(78, 22), detail);

    // ── Seam arc on left cup ─────────────────────────────────────────────────
    final leftSeam = Path()
      ..moveTo(28, 24)
      ..quadraticBezierTo(24, 34, 30, 40);
    canvas.drawPath(leftSeam, detail);

    final rightSeam = Path()
      ..moveTo(72, 24)
      ..quadraticBezierTo(76, 34, 70, 40);
    canvas.drawPath(rightSeam, detail);

    // ── Waist cutoff line ────────────────────────────────────────────────────
    canvas.drawLine(
      const Offset(12, 62),
      const Offset(88, 62),
      Paint()
        ..color = const Color(0xFF777777)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // ── Pedestal ────────────────────────────────────────────────────────────
    final pedestalStem = RRect.fromRectAndRadius(
      const Rect.fromLTWH(38, 62, 24, 7),
      const Radius.circular(2),
    );
    final pedestalBase = RRect.fromRectAndRadius(
      const Rect.fromLTWH(22, 69, 56, 9),
      const Radius.circular(3),
    );
    canvas.drawRRect(pedestalStem, pedestalFill);
    canvas.drawRRect(pedestalBase, pedestalFill);
    canvas.drawRRect(pedestalStem, stroke);
    canvas.drawRRect(pedestalBase, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(BraMannequinPainter old) =>
      old.bodyColor != bodyColor || old.braColor != braColor;
}

class BraMannequinFigure extends StatelessWidget {
  final Color braColor;
  final double width;
  final double height;

  const BraMannequinFigure({
    super.key,
    required this.braColor,
    this.width = 56,
    this.height = 88,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: BraMannequinPainter(braColor: braColor),
    );
  }
}

// ── Full Mannequin Painter ────────────────────────────────────────────────────

/// Draws a simplified standing mannequin figure (flat illustrated style).
class MannequinPainter extends CustomPainter {
  final Color bodyColor;
  final Color outfitTopColor;
  final Color outfitBottomColor;

  const MannequinPainter({
    this.bodyColor = const Color(0xFF90B8CC),
    this.outfitTopColor = const Color(0xFF90B8CC),
    this.outfitBottomColor = const Color(0xFF1C1C1C),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 100;

    canvas.save();
    canvas.scale(sx, sy);

    final bodyFill = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    final topFill = Paint()
      ..color = outfitTopColor
      ..style = PaintingStyle.fill;

    final bottomFill = Paint()
      ..color = outfitBottomColor
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeJoin = StrokeJoin.round;

    final darkStroke = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // ── Head ──────────────────────────────────────────────────────────────
    canvas.drawOval(
      const Rect.fromLTWH(36, 2, 28, 16),
      bodyFill,
    );
    canvas.drawOval(const Rect.fromLTWH(36, 2, 28, 16), stroke);

    // ── Neck ──────────────────────────────────────────────────────────────
    final neck = Path()
      ..moveTo(44, 17)
      ..lineTo(44, 22)
      ..lineTo(56, 22)
      ..lineTo(56, 17)
      ..close();
    canvas.drawPath(neck, bodyFill);

    // ── Torso (outfit top) ────────────────────────────────────────────────
    final torso = Path()
      ..moveTo(30, 22)
      ..lineTo(70, 22)
      ..lineTo(72, 55)
      ..lineTo(28, 55)
      ..close();
    canvas.drawPath(torso, topFill);
    canvas.drawPath(torso, stroke);

    // ── Left arm ──────────────────────────────────────────────────────────
    final lArm = Path()
      ..moveTo(30, 22)
      ..lineTo(16, 25)
      ..lineTo(14, 52)
      ..lineTo(22, 53)
      ..lineTo(28, 35)
      ..lineTo(32, 30)
      ..close();
    canvas.drawPath(lArm, topFill);
    canvas.drawPath(lArm, stroke);

    // ── Right arm ─────────────────────────────────────────────────────────
    final rArm = Path()
      ..moveTo(70, 22)
      ..lineTo(84, 25)
      ..lineTo(86, 52)
      ..lineTo(78, 53)
      ..lineTo(72, 35)
      ..lineTo(68, 30)
      ..close();
    canvas.drawPath(rArm, topFill);
    canvas.drawPath(rArm, stroke);

    // ── Hips / outfit bottom ─────────────────────────────────────────────
    final hips = Path()
      ..moveTo(28, 55)
      ..lineTo(72, 55)
      ..lineTo(74, 62)
      ..lineTo(26, 62)
      ..close();
    canvas.drawPath(hips, topFill);
    canvas.drawPath(hips, stroke);

    // ── Left leg ─────────────────────────────────────────────────────────
    final lLeg = Path()
      ..moveTo(26, 62)
      ..lineTo(48, 62)
      ..lineTo(46, 96)
      ..lineTo(30, 96)
      ..close();
    canvas.drawPath(lLeg, bottomFill);
    canvas.drawPath(lLeg, stroke);

    // ── Right leg ────────────────────────────────────────────────────────
    final rLeg = Path()
      ..moveTo(52, 62)
      ..lineTo(74, 62)
      ..lineTo(70, 96)
      ..lineTo(54, 96)
      ..close();
    canvas.drawPath(rLeg, bottomFill);
    canvas.drawPath(rLeg, stroke);

    // ── Feet / shoes ──────────────────────────────────────────────────────
    final lFoot = Path()
      ..moveTo(28, 95)
      ..lineTo(46, 95)
      ..lineTo(48, 100)
      ..lineTo(24, 100)
      ..close();
    final rFoot = Path()
      ..moveTo(54, 95)
      ..lineTo(72, 95)
      ..lineTo(76, 100)
      ..lineTo(52, 100)
      ..close();
    final shoeColor = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.fill;
    canvas.drawPath(lFoot, shoeColor);
    canvas.drawPath(rFoot, shoeColor);
    canvas.drawPath(lFoot, stroke);
    canvas.drawPath(rFoot, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(MannequinPainter old) =>
      old.bodyColor != bodyColor ||
      old.outfitTopColor != outfitTopColor ||
      old.outfitBottomColor != outfitBottomColor;
}

class MannequinFigure extends StatelessWidget {
  final Color topColor;
  final Color bottomColor;
  final double width;
  final double height;

  const MannequinFigure({
    super.key,
    required this.topColor,
    required this.bottomColor,
    this.width = 80,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: MannequinPainter(
        bodyColor: const Color(0xFF90B8CC),
        outfitTopColor: topColor,
        outfitBottomColor: bottomColor,
      ),
    );
  }
}
