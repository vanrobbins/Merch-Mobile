import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'planogram_slot.dart';

/// Renders a single fixture cell in the bay view.
///
/// Height = [quarterHeight] × [slot.spanQuarters] + gap adjustments.
/// [isActive] highlights the cell with an accent border.
/// [onPress] is called when the user taps the cell (opens product sheet).
class SlotCellWidget extends StatelessWidget {
  const SlotCellWidget({
    super.key,
    required this.slot,
    required this.cellWidth,
    required this.quarterHeight,
    this.isActive = false,
    this.onPress,
  });

  final PgSlot slot;
  final double cellWidth;
  final double quarterHeight;
  final bool isActive;
  final VoidCallback? onPress;

  static const _stripeColor = {
    'shoulder': Color(0x38393735),
    'faceout': Color(0xFF2E6DA4),
    'ubar': AppTheme.accent,
    'shelf': Color(0xFF6B6660),
  };
  static const _pillBg = {
    'shoulder': Color(0x103A3735),
    'faceout': Color(0x1A2E6DA4),
    'ubar': Color(0x1ABF5534),
    'shelf': Color(0x1A6B6660),
  };
  static const _pillFg = {
    'shoulder': AppTheme.textSecondary,
    'faceout': Color(0xFF2E6DA4),
    'ubar': AppTheme.accent,
    'shelf': Color(0xFF6B6660),
  };
  static const _pillLabel = {
    'shoulder': 'SHOULDER',
    'faceout': 'FACE-OUT',
    'ubar': 'U-BAR',
    'shelf': 'SHELF',
  };

  @override
  Widget build(BuildContext context) {
    final h = quarterHeight * slot.spanQuarters +
        (slot.spanQuarters - 1) * 2.0;
    final w = cellWidth * slot.spanCols + (slot.spanCols - 1) * 4.0;

    return GestureDetector(
      onTap: onPress,
      child: SizedBox(
        width: w,
        height: h,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.canvasBg,
            border: Border.all(
              color: isActive ? AppTheme.accent : const Color(0x21393735),
              width: isActive ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 2,
                color: _stripeColor[slot.nodeType] ?? AppTheme.primary,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: slot.items.isEmpty
                          ? _EmptyFixtureContent(nodeType: slot.nodeType)
                          : _buildFilledContent(h),
                    ),
                    Positioned(
                      top: 3,
                      right: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: _pillBg[slot.nodeType],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          _pillLabel[slot.nodeType] ??
                              slot.nodeType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 5.5,
                            fontWeight: DesignTokens.weightBold,
                            letterSpacing: 0.5,
                            color: _pillFg[slot.nodeType] ??
                                AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    if (slot.items.isNotEmpty)
                      const Positioned(
                        bottom: 2,
                        right: 4,
                        child: Text(
                          '2 CU FT',
                          style: TextStyle(
                            fontSize: 5.5,
                            fontWeight: DesignTokens.weightBold,
                            color: Color(0x38393735),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (slot.nodeType == 'shelf')
                Container(height: 3, color: const Color(0x886B6660)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilledContent(double cellH) {
    switch (slot.nodeType) {
      case 'shoulder':
        return _ShoulderContent(slot: slot);
      case 'faceout':
        return _FaceoutContent(slot: slot);
      case 'ubar':
        return _UbarContent(slot: slot);
      case 'shelf':
        return _ShelfContent(slot: slot);
      default:
        return _ShoulderContent(slot: slot);
    }
  }
}

class _EmptyFixtureContent extends StatelessWidget {
  const _EmptyFixtureContent({required this.nodeType});
  final String nodeType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          nodeType == 'shelf'
              ? Icons.table_rows_outlined
              : nodeType == 'ubar'
                  ? Icons.horizontal_rule
                  : nodeType == 'faceout'
                      ? Icons.view_agenda_outlined
                      : Icons.dry_cleaning,
          size: 16,
          color: const Color(0x55393735),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x33393735)),
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Text(
            '+ ADD',
            style: TextStyle(
              fontSize: 6,
              fontWeight: FontWeight.w700,
              color: Color(0x88393735),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShoulderContent extends StatelessWidget {
  const _ShoulderContent({required this.slot});
  final PgSlot slot;

  @override
  Widget build(BuildContext context) {
    if (slot.items.isEmpty) return const SizedBox.shrink();
    final item = slot.items.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('👕', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(
          item.productName,
          style: const TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Text(
          'SHOULDER',
          style: TextStyle(
            fontSize: 6,
            color: AppTheme.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _FaceoutContent extends StatelessWidget {
  const _FaceoutContent({required this.slot});
  final PgSlot slot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${slot.items.length} product${slot.items.length == 1 ? '' : 's'}',
          style: const TextStyle(fontSize: 6.5, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 3),
        ...slot.items.take(5).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _hexColor(item.colorHex) ?? Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      item.productName,
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Color? _hexColor(String? hex) {
    if (hex == null) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }
}

class _UbarContent extends StatelessWidget {
  const _UbarContent({required this.slot});
  final PgSlot slot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: AppTheme.accent, shape: BoxShape.circle)),
            Expanded(
                child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(1)))),
            Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: AppTheme.accent, shape: BoxShape.circle)),
          ],
        ),
        const SizedBox(height: 4),
        ...slot.items.take(4).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Container(
                      width: 2,
                      height: 10,
                      decoration: BoxDecoration(
                          color: const Color(0x66393735),
                          borderRadius: BorderRadius.circular(1))),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0x0D393735),
                          borderRadius: BorderRadius.circular(2)),
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _ShelfContent extends StatelessWidget {
  const _ShelfContent({required this.slot});
  final PgSlot slot;

  @override
  Widget build(BuildContext context) {
    if (slot.items.isEmpty) return const SizedBox.shrink();
    final item = slot.items.first;
    return Row(
      children: [
        const Text('📦', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            item.productName,
            style: const TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Exported for _GridView empty cells in planogram_editor_screen.dart.
class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({required this.color, required this.radius});
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
  bool shouldRepaint(covariant DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
