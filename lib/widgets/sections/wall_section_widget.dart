import 'package:flutter/material.dart';
import '../../models/decorative_element.dart';
import '../../models/display_section.dart';
import '../../models/garment_item.dart';
import '../../models/garment_type.dart';
import '../../models/wall_arm_template.dart';
import '../../theme/app_theme.dart';
import '../painters/fixture_painter.dart';
import '../painters/garment_painter.dart';
import '../painters/mannequin_painter.dart';

class WallSectionWidget extends StatelessWidget {
  final DisplaySection section;
  final void Function(GarmentItem)? onGarmentTap;
  final VoidCallback? onAddGarment;
  final VoidCallback? onFillArms;
  final bool isEditing;

  const WallSectionWidget({
    super.key,
    required this.section,
    this.onGarmentTap,
    this.onAddGarment,
    this.onFillArms,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    // If arm assignments are set, render arm-by-arm view
    if (section.armAssignments != null && section.armAssignments!.isNotEmpty) {
      return _ArmAssignmentView(
        section: section,
        onGarmentTap: onGarmentTap,
        onFillArms: onFillArms,
        isEditing: isEditing,
      );
    }

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

    // Shelf-form mannequins placed on the top shelf
    final shelfForms = section.decorativeElements
        .where((e) => e.onShelf && e.type.isShelfForm)
        .toList();

    final hasMannequin =
        section.mannequinLook != null && section.mannequinLook!.items.isNotEmpty;

    final hasTopShelfContent = shelfItems.isNotEmpty || shelfForms.isNotEmpty;

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
                // Top shelf: garment items + shelf-form mannequins
                if (hasTopShelfContent)
                  _ShelfRow(
                    items: shelfItems,
                    shelfForms: shelfForms,
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
                            hasTopShelf: hasTopShelfContent,
                          ),
                        ),
                      ),

                      // Upper rod garments
                      Positioned(
                        top: hasTopShelfContent ? 76 : 56,
                        left: 8,
                        right: 8,
                        child: _HangingRow(
                          items: upperItems,
                          faceOutCount: section.faceOutCount,
                          uBarCount: section.uBarCount,
                          onTap: onGarmentTap,
                        ),
                      ),

                      // Mid-rack shelves (2ft / 4ft)
                      Positioned(
                        top: 160,
                        left: 8,
                        right: 8,
                        child: _MidShelfRow(items: midItems, onTap: onGarmentTap),
                      ),

                      // Lower rod garments
                      Positioned(
                        top: 210,
                        left: 8,
                        right: 8,
                        child: _HangingRow(
                          items: lowerItems,
                          faceOutCount: section.faceOutCount,
                          uBarCount: section.uBarCount,
                          onTap: onGarmentTap,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isEditing)
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: onAddGarment,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Product'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      if (onFillArms != null)
                        TextButton.icon(
                          onPressed: onFillArms,
                          icon: const Icon(Icons.auto_fix_high, size: 16),
                          label: const Text('Fill Arms'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.accent,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
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

// ── Arm assignment view (template filled) ────────────────────────────────────

class _ArmAssignmentView extends StatelessWidget {
  final DisplaySection section;
  final void Function(GarmentItem)? onGarmentTap;
  final VoidCallback? onFillArms;
  final bool isEditing;

  const _ArmAssignmentView({
    required this.section,
    this.onGarmentTap,
    this.onFillArms,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final assignments = section.armAssignments!;
    final hasMannequin =
        section.mannequinLook != null && section.mannequinLook!.items.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.sectionBorder, width: 0.8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color triangle badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accent.withAlpha(60)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.change_history,
                        size: 11, color: AppTheme.accent),
                    SizedBox(width: 4),
                    Text('COLOR TRIANGLE',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accent,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
              const Spacer(),
              if (isEditing && onFillArms != null)
                TextButton.icon(
                  onPressed: onFillArms,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Re-fill'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    textStyle: const TextStyle(fontSize: 11),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Arm grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: assignments.map((a) {
                return _ArmCell(
                  assignment: a,
                  garments: section.garments,
                  onTap: (g) => onGarmentTap?.call(g),
                );
              }).toList(),
            ),
          ),

          // Mannequin look
          if (hasMannequin) ...[
            const SizedBox(height: 12),
            _WallMannequinPanel(section: section),
          ],
        ],
      ),
    );
  }
}

class _ArmCell extends StatelessWidget {
  final ArmAssignment assignment;
  final List<GarmentItem> garments;
  final void Function(GarmentItem) onTap;

  const _ArmCell({
    required this.assignment,
    required this.garments,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final garment = garments.cast<GarmentItem?>().firstWhere(
          (g) => g?.id == assignment.garmentId,
          orElse: () => null,
        );
    final colorway = garment != null &&
            assignment.colorwayIndex < garment.colorways.length &&
            garment.colorways.isNotEmpty
        ? garment.colorways[assignment.colorwayIndex]
        : null;
    final color = colorway?.color ?? Colors.grey.shade300;

    Color borderColor;
    switch (assignment.armType) {
      case ArmType.faceOut:
        borderColor = AppTheme.accent;
        break;
      case ArmType.uBar:
        borderColor = AppTheme.primary;
        break;
      case ArmType.shelf2ft:
      case ArmType.shelf4ft:
        borderColor = const Color(0xFFC8A870);
        break;
    }

    final isShelf = assignment.armType.isShelf;
    final cellW = isShelf
        ? (assignment.armType == ArmType.shelf4ft ? 80.0 : 48.0)
        : 52.0;

    return GestureDetector(
      onTap: garment != null ? () => onTap(garment) : null,
      child: Container(
        width: cellW,
        margin: const EdgeInsets.only(right: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arm type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: borderColor.withAlpha(25),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: borderColor.withAlpha(80)),
              ),
              child: Text(
                assignment.armType.shortName,
                style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    color: borderColor),
              ),
            ),
            const SizedBox(height: 3),

            // Garment visual
            if (isShelf)
              _ShelfArmCell(
                garment: garment,
                color: color,
                width: cellW,
                capacity: assignment.capacity,
                onTap: garment != null ? () => onTap(garment) : null,
              )
            else
              _HangingArmCell(
                garment: garment,
                color: color,
                capacity: assignment.capacity,
                borderColor: borderColor,
              ),

            const SizedBox(height: 3),
            // Colorway name
            if (colorway != null)
              Text(
                colorway.name,
                style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            // Count badge
            Text(
              '×${assignment.capacity}',
              style: const TextStyle(
                  fontSize: 7, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _HangingArmCell extends StatelessWidget {
  final GarmentItem? garment;
  final Color color;
  final int capacity;
  final Color borderColor;

  const _HangingArmCell({
    required this.garment,
    required this.color,
    required this.capacity,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (garment == null) {
      return Container(
        width: 44,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(
              color: borderColor.withAlpha(40), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
    return Stack(
      children: [
        for (int i = capacity - 1; i >= 0; i--)
          Padding(
            padding: EdgeInsets.only(left: i * 2.0, top: i * 1.0),
            child: GarmentIllustration(
              type: garment!.type,
              color: i == 0 ? color : color.withAlpha(180),
              width: 44,
              height: 52,
            ),
          ),
      ],
    );
  }
}

class _ShelfArmCell extends StatelessWidget {
  final GarmentItem? garment;
  final Color color;
  final double width;
  final int capacity;
  final VoidCallback? onTap;

  const _ShelfArmCell({
    required this.garment,
    required this.color,
    required this.width,
    required this.capacity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E8D0),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFC8A870), width: 2),
          left: BorderSide(color: Color(0xFFD4B880), width: 1),
          right: BorderSide(color: Color(0xFFD4B880), width: 1),
        ),
      ),
      child: garment == null
          ? const Center(
              child: Icon(Icons.add, size: 14, color: AppTheme.textTertiary))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                capacity.clamp(1, 4),
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: FoldedGarmentWidget(
                    type: garment!.type,
                    color: color,
                    width: (width - 8) / capacity.clamp(1, 4),
                    height: 40,
                  ),
                ),
              ),
            ),
    );
  }
}

// ── Shelf row (top shelf / mid-rack shelf) ────────────────────────────────────

class _ShelfRow extends StatelessWidget {
  final List<GarmentItem> items;
  final List<DecorativeElement> shelfForms;
  final String label;
  final void Function(GarmentItem)? onTap;

  const _ShelfRow({
    required this.items,
    this.shelfForms = const [],
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Garment items
            ...items.map((g) {
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
            }),

            // Shelf-form mannequins (half mannequin / bra form)
            ...shelfForms.map((e) => _ShelfFormFigure(element: e)),
          ],
        ),
      ),
    );
  }
}

class _ShelfFormFigure extends StatelessWidget {
  final DecorativeElement element;
  const _ShelfFormFigure({required this.element});

  @override
  Widget build(BuildContext context) {
    final color = element.outfitTopColor?.color ?? AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (element.type == DecorElementType.halfMannequin)
            HalfMannequinFigure(topColor: color, width: 52, height: 80)
          else
            BraMannequinFigure(braColor: color, width: 48, height: 72),
          if (element.label != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                element.label!,
                style: const TextStyle(
                    fontSize: 6.5, color: AppTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Mid-rack shelf row (folded items on 2ft/4ft shelves) ─────────────────────

class _MidShelfRow extends StatelessWidget {
  final List<GarmentItem> items;
  final void Function(GarmentItem)? onTap;

  const _MidShelfRow({required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 2),
          child: Text('MID SHELF',
              style: TextStyle(
                  fontSize: 6.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppTheme.textTertiary)),
        ),
        Container(
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFF0E8D0),
            border: Border(
              bottom: BorderSide(color: Color(0xFFC8A870), width: 2),
              left: BorderSide(color: Color(0xFFD4B880), width: 1),
              right: BorderSide(color: Color(0xFFD4B880), width: 1),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: items.map((g) {
                final color =
                    g.colorways.isNotEmpty ? g.colorways.first.color : Colors.grey;
                return GestureDetector(
                  onTap: () => onTap?.call(g),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FoldedGarmentWidget(
                          type: g.type,
                          color: color,
                          width: 38,
                          height: 32,
                        ),
                        Text(
                          g.name,
                          style: const TextStyle(
                              fontSize: 5.5, color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
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
