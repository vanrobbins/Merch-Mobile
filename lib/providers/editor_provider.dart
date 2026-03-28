import 'package:flutter/foundation.dart';
import '../models/schematic_project.dart';
import '../models/display_section.dart';
import '../models/garment_item.dart';
import '../models/garment_type.dart';
import '../models/color_variant.dart';
import '../models/mannequin_look.dart';

/// Manages auto-layout logic and in-editor selection state.
class EditorProvider extends ChangeNotifier {
  String? _selectedSectionId;
  String? _selectedGarmentId;

  String? get selectedSectionId => _selectedSectionId;
  String? get selectedGarmentId => _selectedGarmentId;

  void selectSection(String? id) {
    _selectedSectionId = id;
    _selectedGarmentId = null;
    notifyListeners();
  }

  void selectGarment(String? id) {
    _selectedGarmentId = id;
    notifyListeners();
  }

  void clearSelection() {
    _selectedSectionId = null;
    _selectedGarmentId = null;
    notifyListeners();
  }

  // ── Auto-Layout Engine ───────────────────────────────────────────────────
  //
  // Given a flat list of garment items (names + types + colors), generate
  // an optimised set of DisplaySections that mirrors real retail VM practice:
  //
  //  • Jackets, hoodies, vests, half/quarter zips → Perimeter Wall upper rod
  //  • T-shirts, long sleeves → Perimeter Wall mid rod (or table fold)
  //  • Joggers, pants, shorts → Perimeter Wall lower rod (or table fold)
  //  • Hats, shoes, accessories → Wall top shelf
  //  • If ≥ 3 colorways of the same product → add to Table folded section
  //  • Pick the garment with the most colorways as the Mannequin Look hero
  //
  // Returns a list of suggested sections; the caller merges them into the
  // project via ProjectsProvider.

  List<DisplaySection> generateAutoLayout(List<GarmentItem> garments) {
    final sections = <DisplaySection>[];

    final shelfItems = garments
        .where((g) => g.type.suggestedPosition == 'shelf')
        .toList();
    final upperRodItems = garments
        .where((g) => g.type.suggestedPosition == 'upper_rod')
        .toList();
    final midRodItems = garments
        .where((g) => g.type.suggestedPosition == 'mid_rod')
        .toList();
    final lowerRodItems = garments
        .where((g) => g.type.suggestedPosition == 'lower_rod')
        .toList();

    // ── Perimeter wall ───────────────────────────────────────────────────
    final wallItems = [...shelfItems, ...upperRodItems, ...midRodItems, ...lowerRodItems];
    if (wallItems.isNotEmpty) {
      final wallFeet = _estimateLinearFeet(wallItems.length);
      sections.add(DisplaySection(
        title: 'Perimeter Wall: ${wallFeet}LF',
        type: SectionType.perimeter,
        linearFeet: wallFeet,
        garments: wallItems,
      ));
    }

    // ── Table (multi-colorway foldables) ─────────────────────────────────
    final tableItems = garments
        .where((g) => g.colorways.length >= 3 && !g.type.isHanging)
        .toList();
    // Also fold mid/lower items with multiple colorways
    final foldableHanging = garments
        .where((g) =>
            g.colorways.length >= 3 &&
            (g.type == GarmentType.tshirt ||
                g.type == GarmentType.jogger ||
                g.type == GarmentType.shorts))
        .toList();

    final allTableItems = {...tableItems, ...foldableHanging}.toList();
    if (allTableItems.isNotEmpty) {
      sections.add(DisplaySection(
        title: _tableTitle(sections.length),
        type: SectionType.table,
        garments: allTableItems,
      ));
    }

    // ── Floor rack (overflow hanging items) ───────────────────────────────
    final floorRackItems = upperRodItems.take(4).toList();
    if (floorRackItems.length >= 2) {
      // Build mannequin look from floor rack items
      final mannequinLook = _buildMannequinLook(floorRackItems, lowerRodItems);
      sections.add(DisplaySection(
        title: 'Floor Rack',
        type: SectionType.floorRack,
        garments: floorRackItems,
        mannequinLook: mannequinLook,
      ));
    }

    return sections;
  }

  int _estimateLinearFeet(int itemCount) {
    if (itemCount <= 4) return 4;
    if (itemCount <= 8) return 8;
    if (itemCount <= 16) return 16;
    return 24;
  }

  String _tableTitle(int sectionCount) {
    final names = ['Primary Table', 'Secondary Table', 'Third Table', 'Fourth Table'];
    return sectionCount < names.length ? names[sectionCount] : 'Table ${sectionCount + 1}';
  }

  MannequinLook _buildMannequinLook(
    List<GarmentItem> tops,
    List<GarmentItem> bottoms,
  ) {
    final items = <MannequinItem>[];

    // Pick first top with a featured colorway
    if (tops.isNotEmpty) {
      final top = tops.first;
      final color = top.colorways.isNotEmpty
          ? top.colorways.first
          : ColorVariant.black;
      items.add(MannequinItem(productName: top.name, colorVariant: color));
    }

    // Pick a bottom
    if (bottoms.isNotEmpty) {
      final bottom = bottoms.first;
      final color = bottom.colorways.isNotEmpty
          ? bottom.colorways.first
          : ColorVariant.black;
      items.add(MannequinItem(productName: bottom.name, colorVariant: color));
    }

    return MannequinLook(items: items);
  }
}
