import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schematic_project.dart';
import '../models/display_section.dart';
import '../models/garment_item.dart';
import '../models/mannequin_look.dart';

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
}
