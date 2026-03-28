import 'package:flutter/material.dart';
import '../../models/display_section.dart';
import '../../models/garment_item.dart';
import '../../models/garment_type.dart';
import '../../theme/app_theme.dart';
import '../painters/fixture_painter.dart';
import '../painters/garment_painter.dart';
import '../painters/mannequin_painter.dart';

class WallSectionWidget extends StatelessWidget {
  final DisplaySection section;
  final void Function(GarmentItem)? onGarmentTap;
  final VoidCallback? onAddGarment;
  final bool isEditing;

  const WallSectionWidget({
    super.key,
    required this.section,
    this.onGarmentTap,
    this.onAddGarment,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final shelfItems = section.garments
        .where((g) => g.type.suggestedPosition == 'shelf')
        .toList();
    final upperItems = section.garments
        .where((g) => g.type.suggestedPosition == 'upper_rod')
        .toList();
    final midItems = section.garments
        .where((g) => g.type.suggestedPosition == 'mid_rod')
        .toList();
    final lowerItems = section.garments
        .where((g) => g.type.suggestedPosition == 'lower_rod')
        .toList();

    final hasMannequin =
        section.mannequinLook != null && section.mannequinLook!.items.isNotEmpty;

    // Determine number of upright bays
    final bays = ((section.linearFeet ?? 8) / 4).ceil().clamp(2, 8);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.sectionBorder, width: 0.8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Previous section note ────────────────────────────────────────
          if (section.previousSectionNote != null)
            RotatedBox(
              quarterTurns: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  section.previousSectionNote!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 7,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          // ── Featured garment callout ─────────────────────────────────────
          if (section.garments.any((g) => g.isFeatured)) ...[
            _FeaturedCallout(garment: section.garments.firstWhere((g) => g.isFeatured)),
            const SizedBox(width: 12),
          ],

          // ── Main wall rack ────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top shelf items
                if (shelfItems.isNotEmpty)
                  _ShelfRow(
                    items: shelfItems,
                    label: 'TOP SHELF',
                    onTap: onGarmentTap,
                  ),

                // Wall rack structure + hanging items
                SizedBox(
                  height: 320,
                  child: Stack(
                    children: [
                      // Rack structure
                      Positioned.fill(
                        child: CustomPaint(
                          painter: WallRackPainter(
                            uprightCount: bays - 1,
                            hasTopShelf: shelfItems.isNotEmpty,
                          ),
                        ),
                      ),

                      // Upper rod garments
                      Positioned(
                        top: shelfItems.isNotEmpty ? 76 : 56,
                        left: 8,
                        right: 8,
                        child: _HangingRow(
                          items: upperItems,
                          faceOutCount: section.faceOutCount,
                          uBarCount: section.uBarCount,
                          onTap: onGarmentTap,
                        ),
                      ),

                      // Lower rod garments
                      Positioned(
                        top: 200,
                        left: 8,
                        right: 8,
                        child: _HangingRow(
                          items: [...midItems, ...lowerItems],
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
                    label: const Text('Add Product'),
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
            const SizedBox(width: 16),
            _WallMannequinPanel(section: section),
          ],

          // ── Next section note ─────────────────────────────────────────────
          if (section.nextSectionNote != null)
            RotatedBox(
              quarterTurns: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  section.nextSectionNote!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 7,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Shelf row ─────────────────────────────────────────────────────────────────

class _ShelfRow extends StatelessWidget {
  final List<GarmentItem> items;
  final String label;
  final void Function(GarmentItem)? onTap;

  const _ShelfRow({required this.items, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: items.map((g) {
              final color = g.colorways.isNotEmpty
                  ? g.colorways.first.color
                  : Colors.grey;
              return GestureDetector(
                onTap: () => onTap?.call(g),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      GarmentIllustration(
                        type: g.type,
                        color: color,
                        width: 48,
                        height: 40,
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: 50,
                        child: Text(
                          g.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 6.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Hanging row ───────────────────────────────────────────────────────────────

class _HangingRow extends StatelessWidget {
  final List<GarmentItem> items;
  final int faceOutCount;
  final int uBarCount;
  final void Function(GarmentItem)? onTap;

  const _HangingRow({
    required this.items,
    required this.faceOutCount,
    required this.uBarCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((g) {
        final isFaceOut = g.type.suggestedPosition == 'upper_rod';
        final count = isFaceOut ? faceOutCount : uBarCount;
        final color = g.colorways.isNotEmpty
            ? g.colorways.first.color
            : Colors.grey;

        return GestureDetector(
          onTap: () => onTap?.call(g),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show stacked garments to indicate face-out / u-bar count
              Stack(
                children: [
                  for (int i = count - 1; i >= 0; i--)
                    Padding(
                      padding: EdgeInsets.only(left: i * 3.0, top: i * 1.0),
                      child: GarmentIllustration(
                        type: g.type,
                        color: i == 0 ? color : color.withAlpha(180),
                        width: 44,
                        height: 52,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: 52,
                child: Text(
                  g.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 6.5,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.2,
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

// ── Featured callout box ──────────────────────────────────────────────────────

class _FeaturedCallout extends StatelessWidget {
  final GarmentItem garment;

  const _FeaturedCallout({required this.garment});

  @override
  Widget build(BuildContext context) {
    final color = garment.colorways.isNotEmpty
        ? garment.colorways.first.color
        : Colors.blue;

    return Container(
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.accent, width: 1.5),
        color: AppTheme.cardBg,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          GarmentIllustration(
            type: garment.type,
            color: color,
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 6),
          Text(
            garment.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppTheme.textPrimary,
            ),
          ),
          if (garment.colorways.isNotEmpty)
            Text(
              garment.colorways.first.name,
              style: const TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Mannequin panel on wall ───────────────────────────────────────────────────

class _WallMannequinPanel extends StatelessWidget {
  final DisplaySection section;

  const _WallMannequinPanel({required this.section});

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

    return SizedBox(
      width: 120,
      child: Column(
        children: [
          MannequinFigure(
            topColor: topColor,
            bottomColor: bottomColor,
            width: 80,
            height: 160,
          ),
          const SizedBox(height: 6),
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
    );
  }
}
