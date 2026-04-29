import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'planogram_slot.dart';
import 'slot_silhouette_renderer.dart';

/// A single cell in the planogram editor grid.
///
/// [isActive] — long-press-activated; shows drag handles.
/// [isBlocked] — occupied by a spanning neighbour; shows lock icon.
/// [cellWidth]/[cellHeight] — base cell dimensions.
///
/// Drag handles appear on the right edge (spanCols) and bottom edge (spanRows).
/// The top-right corner handle cycles rotation.
class SlotCellWidget extends StatelessWidget {
  const SlotCellWidget({
    super.key,
    required this.slot,
    required this.isActive,
    required this.isBlocked,
    required this.cellWidth,
    required this.cellHeight,
    required this.productType,
    this.onTap,
    this.onLongPress,
    this.onSpanColsDrag, // new spanCols value
    this.onSpanRowsDrag, // new spanRows value
    this.onRotate,
  });

  final PgSlot slot;
  final bool isActive;
  final bool isBlocked;
  final double cellWidth;
  final double cellHeight;
  final String? productType;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<int>? onSpanColsDrag;
  final ValueChanged<int>? onSpanRowsDrag;
  final VoidCallback? onRotate;

  @override
  Widget build(BuildContext context) {
    // The actual displayed width accounts for span
    final w = cellWidth * slot.spanCols + (slot.spanCols - 1) * 4.0;
    final h = cellHeight * slot.spanRows + (slot.spanRows - 1) * 4.0;

    if (isBlocked) {
      return SizedBox(
        width: cellWidth,
        height: cellHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Center(
            child: Icon(Icons.lock_outline, size: 14, color: Colors.grey),
          ),
        ),
      );
    }

    final hasProduct = slot.productId != null;

    Widget content = _buildCellContent(hasProduct, w, h);

    if (isActive) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          // Right edge — spanCols drag handle
          Positioned(
            right: -10,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragUpdate: (d) {
                if (onSpanColsDrag == null) return;
                final newSpan =
                    (slot.spanCols + (d.delta.dx / cellWidth).round())
                        .clamp(1, 4);
                onSpanColsDrag!(newSpan);
              },
              child: Container(
                width: 20,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppTheme.accent.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Icon(Icons.chevron_right,
                    size: 14, color: Colors.white),
              ),
            ),
          ),
          // Bottom edge — spanRows drag handle
          Positioned(
            left: 0,
            right: 0,
            bottom: -10,
            child: GestureDetector(
              onVerticalDragUpdate: (d) {
                if (onSpanRowsDrag == null) return;
                final newSpan =
                    (slot.spanRows + (d.delta.dy / cellHeight).round())
                        .clamp(1, 6);
                onSpanRowsDrag!(newSpan);
              },
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppTheme.accent.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Icon(Icons.expand_more,
                    size: 14, color: Colors.white),
              ),
            ),
          ),
          // Top-right corner — rotation
          Positioned(
            right: -8,
            top: -8,
            child: GestureDetector(
              onTap: onRotate,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rotate_90_degrees_cw,
                    size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(width: w, height: h, child: content),
    );
  }

  Widget _buildCellContent(bool hasProduct, double w, double h) {
    if (!hasProduct) {
      // Empty cell — dashed border + plus icon
      return CustomPaint(
        painter: _DashedBorderPainter(
            color: Colors.grey.shade400, radius: 2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Center(
            child: Icon(Icons.add, size: 20, color: Colors.grey),
          ),
        ),
      );
    }

    // Filled slot
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.canvasBg,
        border: isActive
            ? Border.all(color: AppTheme.accent, width: 2)
            : Border.all(
                // ignore: deprecated_member_use
                color: AppTheme.primary.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SlotSilhouetteRenderer(
            slot: slot,
            productType: productType,
            width: w - 16,
            height: (h - 28).clamp(20.0, 80.0),
          ),
          const SizedBox(height: 2),
          Text(
            slot.productName ?? '',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            _modeLabel(slot.presentationMode),
            style: const TextStyle(
              fontSize: 7,
              color: AppTheme.textSecondary,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
          ),
        ],
      ),
    );
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'shoulder_out': return 'SHOULDER';
      case 'folded':       return 'FOLD';
      case 'face_out':
      default:             return 'FACE';
    }
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, Radius.circular(radius)));
    const dash = 4.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        canvas.drawPath(
            metric.extractPath(dist, (dist + dash).clamp(0.0, metric.length)),
            paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
