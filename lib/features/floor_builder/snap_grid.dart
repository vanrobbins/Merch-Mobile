import 'package:flutter/material.dart';

class SnapGrid extends StatelessWidget {
  const SnapGrid({super.key, required this.gridSizeFt, required this.pixelsPerFt});
  final double gridSizeFt;
  final double pixelsPerFt;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _SnapGridPainter(gridSizeFt: gridSizeFt, pixelsPerFt: pixelsPerFt),
  );
}

class _SnapGridPainter extends CustomPainter {
  const _SnapGridPainter({required this.gridSizeFt, required this.pixelsPerFt});
  final double gridSizeFt;
  final double pixelsPerFt;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;
    final step = gridSizeFt * pixelsPerFt;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_SnapGridPainter old) =>
      old.gridSizeFt != gridSizeFt || old.pixelsPerFt != pixelsPerFt;
}
