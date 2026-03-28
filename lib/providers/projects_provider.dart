import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schematic_project.dart';
import '../models/display_section.dart';
import '../models/garment_item.dart';
import '../models/mannequin_look.dart';
import '../models/store_zone.dart';
import '../models/store_template.dart';
import '../models/wall_arm_template.dart';
import '../models/schematic_project.dart' show StorePoint;

class ProjectsProvider extends ChangeNotifier {
  static const _storageKey = 'merch_mobile_projects';

  List<SchematicProject> _projects = [];

  List<SchematicProject> get projects =>
      List.unmodifiable(_projects)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw) as List;
      _projects = decoded
          .map((e) => SchematicProject.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
    await Future.wait([loadTemplates(), loadArmTemplates()]);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_projects.map((p) => p.toJson()).toList()),
    );
  }

  // ── Project CRUD ─────────────────────────────────────────────────────────

  Future<SchematicProject> createProject({
    required String name,
    String? storeName,
  }) async {
    final project = SchematicProject(name: name, storeName: storeName);
    _projects.add(project);
    notifyListeners();
    await _save();
    return project;
  }

  Future<void> updateProject(SchematicProject project) async {
    final idx = _projects.indexWhere((p) => p.id == project.id);
    if (idx == -1) return;
    _projects[idx] = project;
    notifyListeners();
    await _save();
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
    await _save();
  }

  SchematicProject? getProject(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Section CRUD ─────────────────────────────────────────────────────────

  Future<void> addSection(String projectId, DisplaySection section) async {
    final project = getProject(projectId);
    if (project == null) return;
    await updateProject(
      project.copyWith(sections: [...project.sections, section]),
    );
  }

  Future<void> updateSection(String projectId, DisplaySection section) async {
    final project = getProject(projectId);
    if (project == null) return;
    final sections = project.sections.map((s) {
      return s.id == section.id ? section : s;
    }).toList();
    await updateProject(project.copyWith(sections: sections));
  }

  Future<void> deleteSection(String projectId, String sectionId) async {
    final project = getProject(projectId);
    if (project == null) return;
    await updateProject(
      project.copyWith(
        sections: project.sections.where((s) => s.id != sectionId).toList(),
      ),
    );
  }

  Future<void> reorderSections(
      String projectId, int oldIndex, int newIndex) async {
    final project = getProject(projectId);
    if (project == null) return;
    final sections = [...project.sections];
    final item = sections.removeAt(oldIndex);
    sections.insert(newIndex, item);
    await updateProject(project.copyWith(sections: sections));
  }

  // ── Garment CRUD ─────────────────────────────────────────────────────────

  Future<void> addGarment(
      String projectId, String sectionId, GarmentItem garment) async {
    final project = getProject(projectId);
    if (project == null) return;
    final sections = project.sections.map((s) {
      if (s.id != sectionId) return s;
      return s.copyWith(garments: [...s.garments, garment]);
    }).toList();
    await updateProject(project.copyWith(sections: sections));
  }

  Future<void> updateGarment(
      String projectId, String sectionId, GarmentItem garment) async {
    final project = getProject(projectId);
    if (project == null) return;
    final sections = project.sections.map((s) {
      if (s.id != sectionId) return s;
      return s.copyWith(
        garments: s.garments.map((g) => g.id == garment.id ? garment : g).toList(),
      );
    }).toList();
    await updateProject(project.copyWith(sections: sections));
  }

  Future<void> deleteGarment(
      String projectId, String sectionId, String garmentId) async {
    final project = getProject(projectId);
    if (project == null) return;
    final sections = project.sections.map((s) {
      if (s.id != sectionId) return s;
      return s.copyWith(
        garments: s.garments.where((g) => g.id != garmentId).toList(),
      );
    }).toList();
    await updateProject(project.copyWith(sections: sections));
  }

  // ── Mannequin Look ───────────────────────────────────────────────────────

  Future<void> setMannequinLook(
      String projectId, String sectionId, MannequinLook? look) async {
    final project = getProject(projectId);
    if (project == null) return;
    final sections = project.sections.map((s) {
      if (s.id != sectionId) return s;
      return look == null
          ? s.copyWith(clearMannequin: true)
          : s.copyWith(mannequinLook: look);
    }).toList();
    await updateProject(project.copyWith(sections: sections));
  }

  // ── Section layout position ───────────────────────────────────────────────

  Future<void> setSectionLayout(
    String projectId,
    String sectionId, {
    WallSide? wallSide,
    double? layoutPosition,
    double? layoutX,
    double? layoutY,
    String? zoneId,
    bool clearZone = false,
  }) async {
    final project = getProject(projectId);
    if (project == null) return;
    final sections = project.sections.map((s) {
      if (s.id != sectionId) return s;
      return s.copyWith(
        wallSide: wallSide,
        layoutPosition: layoutPosition,
        layoutX: layoutX,
        layoutY: layoutY,
        zoneId: zoneId,
        clearZone: clearZone,
      );
    }).toList();
    await updateProject(project.copyWith(sections: sections));
  }

  // ── Zone CRUD ─────────────────────────────────────────────────────────────

  Future<StoreZone> addZone(String projectId, StoreZone zone) async {
    final project = getProject(projectId);
    if (project == null) return zone;
    await updateProject(
        project.copyWith(zones: [...project.zones, zone]));
    return zone;
  }

  Future<void> updateZone(String projectId, StoreZone zone) async {
    final project = getProject(projectId);
    if (project == null) return;
    final zones = project.zones.map((z) => z.id == zone.id ? zone : z).toList();
    await updateProject(project.copyWith(zones: zones));
  }

  Future<void> deleteZone(String projectId, String zoneId) async {
    final project = getProject(projectId);
    if (project == null) return;
    // Unzone all sections in this zone
    final sections = project.sections.map((s) {
      if (s.zoneId == zoneId) return s.copyWith(clearZone: true);
      return s;
    }).toList();
    await updateProject(project.copyWith(
      zones: project.zones.where((z) => z.id != zoneId).toList(),
      sections: sections,
    ));
  }

  Future<void> updateStoreDimensions(
    String projectId, {
    double? widthFt,
    double? depthFt,
    List<StorePoint>? polygon,
  }) async {
    final project = getProject(projectId);
    if (project == null) return;
    await updateProject(project.copyWith(
      storeWidthFt: widthFt,
      storeDepthFt: depthFt,
      storePolygon: polygon,
    ));
  }

  // ── Templates ─────────────────────────────────────────────────────────────

  static const _templateKey = 'merch_mobile_templates';
  List<StoreTemplate> _templates = [];
  List<StoreTemplate> get templates => List.unmodifiable(_templates);

  Future<void> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_templateKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw) as List;
      _templates = decoded
          .map((e) => StoreTemplate.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> saveTemplate(StoreTemplate template) async {
    _templates.removeWhere((t) => t.id == template.id);
    _templates.add(template);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _templateKey,
      jsonEncode(_templates.map((t) => t.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> deleteTemplate(String templateId) async {
    _templates.removeWhere((t) => t.id == templateId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _templateKey,
      jsonEncode(_templates.map((t) => t.toJson()).toList()),
    );
    notifyListeners();
  }

  // ── Wall Arm Templates ────────────────────────────────────────────────────

  static const _armTemplateKey = 'merch_mobile_arm_templates';
  List<WallArmTemplate> _armTemplates = [];
  List<WallArmTemplate> get armTemplates => List.unmodifiable(_armTemplates);

  Future<void> loadArmTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_armTemplateKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw) as List;
      _armTemplates = decoded
          .map((e) => WallArmTemplate.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> saveArmTemplate(WallArmTemplate template) async {
    _armTemplates.removeWhere((t) => t.id == template.id);
    _armTemplates.add(template);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _armTemplateKey,
      jsonEncode(_armTemplates.map((t) => t.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> deleteArmTemplate(String templateId) async {
    _armTemplates.removeWhere((t) => t.id == templateId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _armTemplateKey,
      jsonEncode(_armTemplates.map((t) => t.toJson()).toList()),
    );
    notifyListeners();
  }

  /// Apply a wall arm template to a perimeter wall section, filling arms
  /// with [garment] using color-triangle distribution.
  Future<void> applyArmTemplate(
    String projectId,
    String sectionId,
    WallArmTemplate template,
    GarmentItem garment,
  ) async {
    final cwIndices = List<int>.generate(garment.colorways.length, (i) => i);
    final assignments = template.autoFill(garment.id, cwIndices);
    final project = getProject(projectId);
    if (project == null) return;
    final sections = project.sections.map((s) {
      if (s.id != sectionId) return s;
      // Ensure the garment is in the section
      final hasGarment = s.garments.any((g) => g.id == garment.id);
      final garments = hasGarment ? s.garments : [...s.garments, garment];
      return s.copyWith(garments: garments, armAssignments: assignments);
    }).toList();
    await updateProject(project.copyWith(sections: sections));
  }

  // ── Apply store template ───────────────────────────────────────────────────

  /// Apply a template to a project: sets store dimensions, polygon, zones,
  /// and creates empty sections from the template stubs.
  Future<void> applyTemplate(String projectId, StoreTemplate template) async {
    final project = getProject(projectId);
    if (project == null) return;
    // Remap zone IDs to fresh ones
    final zoneIdMap = <String, String>{};
    final newZones = template.zones.map((z) {
      final newZone = StoreZone(
        name: z.name,
        colorValue: z.colorValue,
        sectionIds: [],
      );
      zoneIdMap[z.id] = newZone.id;
      return newZone;
    }).toList();

    final newSections = template.sectionStubs.map((stub) {
      final remappedZoneId =
          stub.zoneId != null ? zoneIdMap[stub.zoneId] : null;
      return stub.toSection().copyWith(zoneId: remappedZoneId);
    }).toList();

    await updateProject(project.copyWith(
      storeWidthFt: template.storeWidthFt,
      storeDepthFt: template.storeDepthFt,
      zones: newZones,
      sections: [...project.sections, ...newSections],
    ));
  }
}
