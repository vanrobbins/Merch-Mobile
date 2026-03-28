import 'package:flutter/material.dart';
import '../../models/display_section.dart';
import '../../models/garment_item.dart';
import '../../theme/app_theme.dart';
import '../painters/fixture_painter.dart';
import '../painters/garment_painter.dart';
import '../painters/mannequin_painter.dart';

class RackSectionWidget extends StatelessWidget {
  final DisplaySection section;
  final void Function(GarmentItem)? onGarmentTap;
  final VoidCallback? onAddGarment;
  final bool isEditing;

  const RackSectionWidget({
    super.key,
    required this.section,
    this.onGarmentTap,
    this.onAddGarment,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasMannequin =
        section.mannequinLook != null && section.mannequinLook!.items.isNotEmpty;

    // Split into upper and lower crossbar groups
    final upper = section.garments.take(4).toList();
    final lower = section.garments.skip(4).take(4).toList();

    return Container(
      color: AppTheme.cardBg,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── T-bar rack ───────────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 340,
                  child: Stack(
                    children: [
                      // Rack structure
                      Positioned.fill(
                        child: CustomPaint(painter: const TBarRackPainter()),
                      ),

                      // Upper crossbar items
                      Positioned(
                        top: 16,
                        left: 4,
                        right: 4,
                        child: _RackRow(
                          items: upper,
                          faceOutCount: section.faceOutCount,
                          uBarCount: section.uBarCount,
                          onTap: onGarmentTap,
                        ),
                      ),

                      // Lower crossbar items
                      if (lower.isNotEmpty)
                        Positioned(
                          top: 172,
                          left: 4,
                          right: 4,
                          child: _RackRow(
                            items: lower,
                            faceOutCount: section.faceOutCount,
                            uBarCount: section.uBarCount,
                            onTap: onGarmentTap,
                          ),
                        ),
                    ],
                  ),
                ),

                if (isEditing)
                  TextButton.icon(
                    onPressed: onAddGarment,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('ADD PRODUCT'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // ── Mannequin look ────────────────────────────────────────────────
          if (hasMannequin) ...[
            const SizedBox(width: 20),
            SizedBox(
              width: 130,
              child: _RackMannequinPanel(section: section),
            ),
          ],
        ],
      ),
    );
  }
}

class _RackRow extends StatelessWidget {
  final List<GarmentItem> items;
  final int faceOutCount;
  final int uBarCount;
  final void Function(GarmentItem)? onTap;

  const _RackRow({
    required this.items,
    required this.faceOutCount,
    required this.uBarCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((g) {
        final isFaceOut = g.type.suggestedPosition == 'upper_rod';
        final count = isFaceOut ? faceOutCount : uBarCount;
        final color =
            g.colorways.isNotEmpty ? g.colorways.first.color : Colors.grey;

        return GestureDetector(
          onTap: () => onTap?.call(g),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show hanger above garment
              CustomPaint(
                size: const Size(28, 18),
                painter: HangerPainter(color: AppTheme.rackerColor),
              ),
              // Stacked garments for face-out/u-bar count
              Stack(
                children: [
                  for (int i = count - 1; i >= 0; i--)
                    Padding(
                      padding: EdgeInsets.only(left: i * 2.5, top: i * 0.8),
                      child: GarmentIllustration(
                        type: g.type,
                        color: i == 0 ? color : color.withAlpha(160),
                        width: 42,
                        height: 52,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: 48,
                child: Text(
                  g.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 6,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RackMannequinPanel extends StatelessWidget {
  final DisplaySection section;

  const _RackMannequinPanel({required this.section});

  @override
  Widget build(BuildContext context) {
    final look = section.mannequinLook!;
    final items = look.items;
    final topColor = items.isNotEmpty
        ? items.first.colorVariant.color
        : const Color(0xFF90B8CC);
    final bottomColor = items.length > 1
        ? items[1].colorVariant.color
        : const Color(0xFF1C1C1C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MannequinFigure(
          topColor: topColor,
          bottomColor: bottomColor,
          width: 80,
          height: 160,
        ),
        const SizedBox(height: 8),
        const Text(
          'MANNEQUIN LOOK',
          style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w800,
            color: AppTheme.accent,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 7.5,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(text: '• ${item.productName}\n  '),
                    TextSpan(
                      text: item.colorVariant.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
