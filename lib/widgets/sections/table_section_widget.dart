import 'package:flutter/material.dart';
import '../../models/display_section.dart';
import '../../models/garment_item.dart';
import '../../theme/app_theme.dart';
import '../painters/mannequin_painter.dart';
import '../painters/fixture_painter.dart';
import '../painters/garment_painter.dart';
import 'colorway_grid.dart';

class TableSectionWidget extends StatelessWidget {
  final DisplaySection section;
  final void Function(GarmentItem)? onGarmentTap;
  final VoidCallback? onAddGarment;
  final bool isEditing;

  const TableSectionWidget({
    super.key,
    required this.section,
    this.onGarmentTap,
    this.onAddGarment,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = sortByTablePriority(section.garments);
    final hasMannequin = section.mannequinLook != null &&
        section.mannequinLook!.items.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.sectionBorder, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: Folded colorway grids ──────────────────────────────────
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sorted.isEmpty)
                  _emptyState(context)
                else
                  ...sorted.map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ColorwayGrid(
                          garment: g,
                          itemSize: 60,
                          isFeatured: g.isFeatured,
                          onTap: () => onGarmentTap?.call(g),
                        ),
                      )),
                if (isEditing)
                  TextButton.icon(
                    onPressed: onAddGarment,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Product'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // ── Right: T-bar rack + mannequin ────────────────────────────────
          if (hasMannequin) ...[
            const SizedBox(width: 16),
            SizedBox(
              width: 160,
              child: _MannequinPanel(section: section),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Text(
        'No products yet',
        style: TextStyle(
          color: AppTheme.textTertiary,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _MannequinPanel extends StatelessWidget {
  final DisplaySection section;

  const _MannequinPanel({required this.section});

  @override
  Widget build(BuildContext context) {
    final look = section.mannequinLook!;
    final items = look.items;

    // Extract top and bottom colors for mannequin figure
    final topColor = items.isNotEmpty
        ? items.first.colorVariant.color
        : const Color(0xFF90B8CC);
    final bottomColor = items.length > 1
        ? items[1].colorVariant.color
        : const Color(0xFF1C1C1C);

    // Rack items (first 3 items shown hanging)
    final rackGarments = section.garments.take(3).toList();

    return Column(
      children: [
        // T-bar rack with hanging items
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 140,
              height: 180,
              child: Stack(
                children: [
                  // Rack background
                  Positioned.fill(
                    child: CustomPaint(painter: const TBarRackPainter()),
                  ),
                  // Hanging garments
                  Positioned(
                    top: 16,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: rackGarments.map((g) {
                        final color = g.colorways.isNotEmpty
                            ? g.colorways.first.color
                            : const Color(0xFF888888);
                        return Column(
                          children: [
                            GarmentIllustration(
                              type: g.type,
                              color: color,
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: 38,
                              child: Text(
                                g.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 6,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Mannequin figure
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MannequinFigure(
              topColor: topColor,
              bottomColor: bottomColor,
              width: 70,
              height: 140,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MANNEQUIN LOOK',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accent,
                      letterSpacing: 0.6,
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
                              TextSpan(text: '• ${item.productName} – '),
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
              ),
            ),
          ],
        ),
      ],
    );
  }
}
