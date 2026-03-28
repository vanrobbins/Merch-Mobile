import 'package:flutter/material.dart';

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
