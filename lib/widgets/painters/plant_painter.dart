import 'package:flutter/material.dart';

/// Draws a simple potted plant silhouette (leafy / floor plant style).
class PlantPainter extends CustomPainter {
  final PlantStyle style;

  const PlantPainter({this.style = PlantStyle.leafy});

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 100;
    canvas.save();
    canvas.scale(sx, sy);

    switch (style) {
      case PlantStyle.leafy:
        _drawLeafy(canvas);
      case PlantStyle.tall:
        _drawTall(canvas);
      case PlantStyle.small:
        _drawSmall(canvas);
    }

    canvas.restore();
  }

  void _drawLeafy(Canvas canvas) {
    final potPaint = Paint()
      ..color = const Color(0xFFC4A882)
      ..style = PaintingStyle.fill;
    final potStroke = Paint()
      ..color = const Color(0xFF8B6A3E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final leafPaint = Paint()
      ..color = const Color(0xFF3A7D44)
      ..style = PaintingStyle.fill;
    final leafStroke = Paint()
      ..color = const Color(0xFF2D5E34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final soilPaint = Paint()
      ..color = const Color(0xFF6B4226)
      ..style = PaintingStyle.fill;

    // Pot body
    final pot = Path()
      ..moveTo(30, 72)
      ..lineTo(25, 96)
      ..lineTo(75, 96)
      ..lineTo(70, 72)
      ..close();
    canvas.drawPath(pot, potPaint);
    canvas.drawPath(pot, potStroke);

    // Pot rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(22, 68, 56, 8), const Radius.circular(2)),
      potPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(22, 68, 56, 8), const Radius.circular(2)),
      potStroke,
    );

    // Soil
    canvas.drawOval(const Rect.fromLTWH(24, 68, 52, 10), soilPaint);

    // Left leaf cluster
    final lLeaf1 = Path()
      ..moveTo(50, 65)
      ..quadraticBezierTo(20, 55, 15, 30)
      ..quadraticBezierTo(35, 45, 50, 65)
      ..close();
    final lLeaf2 = Path()
      ..moveTo(50, 65)
      ..quadraticBezierTo(10, 50, 18, 20)
      ..quadraticBezierTo(38, 40, 50, 65)
      ..close();

    // Right leaf cluster
    final rLeaf1 = Path()
      ..moveTo(50, 65)
      ..quadraticBezierTo(80, 55, 85, 30)
      ..quadraticBezierTo(65, 45, 50, 65)
      ..close();
    final rLeaf2 = Path()
      ..moveTo(50, 65)
      ..quadraticBezierTo(90, 50, 82, 20)
      ..quadraticBezierTo(62, 40, 50, 65)
      ..close();

    // Center tall leaf
    final cLeaf = Path()
      ..moveTo(50, 65)
      ..quadraticBezierTo(40, 35, 50, 5)
      ..quadraticBezierTo(60, 35, 50, 65)
      ..close();

    for (final leaf in [lLeaf2, lLeaf1, rLeaf2, rLeaf1, cLeaf]) {
      canvas.drawPath(leaf, leafPaint);
      canvas.drawPath(leaf, leafStroke);
    }
  }

  void _drawTall(Canvas canvas) {
    final potPaint = Paint()
      ..color = const Color(0xFFC4A882)
      ..style = PaintingStyle.fill;
    final potStroke = Paint()
      ..color = const Color(0xFF8B6A3E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final trunkPaint = Paint()
      ..color = const Color(0xFF8B5E3C)
      ..style = PaintingStyle.fill;
    final leafPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;
    final leafStroke = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Pot
    final pot = Path()
      ..moveTo(33, 80)
      ..lineTo(28, 98)
      ..lineTo(72, 98)
      ..lineTo(67, 80)
      ..close();
    canvas.drawPath(pot, potPaint);
    canvas.drawPath(pot, potStroke);

    // Trunk
    canvas.drawRect(const Rect.fromLTWH(46, 30, 8, 52), trunkPaint);

    // Palm fronds / wide leaves
    final leaves = [
      _palmFrond(50, 30, -60),
      _palmFrond(50, 30, -40),
      _palmFrond(50, 30, -20),
      _palmFrond(50, 30, 0),
      _palmFrond(50, 30, 20),
      _palmFrond(50, 30, 40),
      _palmFrond(50, 30, 60),
    ];
    for (final leaf in leaves) {
      canvas.drawPath(leaf, leafPaint);
      canvas.drawPath(leaf, leafStroke);
    }
  }

  Path _palmFrond(double x, double y, double angle) {
    // Simplified frond as a tapered leaf at given angle (degrees from vertical)
    final rad = angle * 3.14159 / 180;
    final dx = 28 * _sin(rad);
    final dy = -28 * _cos(rad);
    final p = Path()
      ..moveTo(x, y)
      ..quadraticBezierTo(
          x + dx * 0.5 - dy * 0.2, y + dy * 0.5 + dx * 0.2,
          x + dx, y + dy)
      ..quadraticBezierTo(
          x + dx * 0.5 + dy * 0.2, y + dy * 0.5 - dx * 0.2,
          x, y)
      ..close();
    return p;
  }

  double _sin(double r) => (r - r * r * r / 6 + r * r * r * r * r / 120);
  double _cos(double r) =>
      (1 - r * r / 2 + r * r * r * r / 24);

  void _drawSmall(Canvas canvas) {
    final potPaint = Paint()
      ..color = const Color(0xFFE07B54)
      ..style = PaintingStyle.fill;
    final potStroke = Paint()
      ..color = const Color(0xFFBF5130)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final leafPaint = Paint()
      ..color = const Color(0xFF558B2F)
      ..style = PaintingStyle.fill;
    final leafStroke = Paint()
      ..color = const Color(0xFF33691E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final soilPaint = Paint()
      ..color = const Color(0xFF6B4226)
      ..style = PaintingStyle.fill;

    // Round pot
    canvas.drawOval(const Rect.fromLTWH(28, 64, 44, 34), potPaint);
    canvas.drawOval(const Rect.fromLTWH(28, 64, 44, 34), potStroke);

    // Rim
    canvas.drawOval(const Rect.fromLTWH(25, 60, 50, 12), potPaint);
    canvas.drawOval(const Rect.fromLTWH(25, 60, 50, 12), potStroke);

    // Soil
    canvas.drawOval(const Rect.fromLTWH(28, 62, 44, 8), soilPaint);

    // Small round succulent leaves
    final positions = [
      [50.0, 48.0, 18.0, 16.0],
      [36.0, 52.0, 16.0, 14.0],
      [64.0, 52.0, 16.0, 14.0],
      [42.0, 40.0, 14.0, 12.0],
      [58.0, 40.0, 14.0, 12.0],
      [50.0, 34.0, 12.0, 10.0],
    ];
    for (final pos in positions) {
      canvas.drawOval(
        Rect.fromLTWH(pos[0] - pos[2] / 2, pos[1] - pos[3] / 2, pos[2], pos[3]),
        leafPaint,
      );
      canvas.drawOval(
        Rect.fromLTWH(pos[0] - pos[2] / 2, pos[1] - pos[3] / 2, pos[2], pos[3]),
        leafStroke,
      );
    }
  }

  @override
  bool shouldRepaint(PlantPainter old) => old.style != style;
}

enum PlantStyle { leafy, tall, small }

extension PlantStyleX on PlantStyle {
  String get displayName => switch (this) {
        PlantStyle.leafy => 'Leafy Plant',
        PlantStyle.tall => 'Tall Plant',
        PlantStyle.small => 'Small / Succulent',
      };
}

class PlantWidget extends StatelessWidget {
  final PlantStyle style;
  final double width;
  final double height;

  const PlantWidget({
    super.key,
    this.style = PlantStyle.leafy,
    this.width = 60,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: PlantPainter(style: style),
    );
  }
}
