import 'package:flutter/material.dart';
import '../../models/garment_item.dart';
import '../../models/garment_type.dart';
import '../../theme/app_theme.dart';
import '../painters/garment_painter.dart';

/// Priority order for folded table display.
const _tablePriority = [
  GarmentType.hoodie,
  GarmentType.halfZip,
  GarmentType.quarterZip,
  GarmentType.tshirt,
  GarmentType.pants,
  GarmentType.jogger,
  GarmentType.shorts,
  GarmentType.vest,
  GarmentType.jacket,
  GarmentType.hat,
  GarmentType.shoes,
  GarmentType.accessory,
];

/// Sorts garments by table priority.
List<GarmentItem> sortByTablePriority(List<GarmentItem> items) {
  final sorted = [...items];
  sorted.sort((a, b) {
    final ai = _tablePriority.indexOf(a.type);
    final bi = _tablePriority.indexOf(b.type);
    final ap = ai == -1 ? 999 : ai;
    final bp = bi == -1 ? 999 : bi;
    return ap.compareTo(bp);
  });
  return sorted;
}

/// Renders one garment's colorway grid (multiple folds side by side).
/// Each "fold" shows the garment in one color variant.
class ColorwayGrid extends StatelessWidget {
  final GarmentItem garment;
  final double itemSize;
  final bool isFeatured;
  final VoidCallback? onTap;

  const ColorwayGrid({
    super.key,
    required this.garment,
    this.itemSize = 64,
    this.isFeatured = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isFeatured ? AppTheme.accent : AppTheme.sectionBorder,
            width: isFeatured ? 2.0 : 0.8,
          ),
          color: AppTheme.cardBg,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Garment swatches row
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: garment.colorways.map((cv) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GarmentIllustration(
                      type: garment.type,
                      color: cv.color,
                      width: itemSize,
                      height: itemSize,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cv.name,
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 6),

            // Product name label
            Text(
              garment.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
