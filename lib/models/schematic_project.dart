import 'package:uuid/uuid.dart';
import 'display_section.dart';

class SchematicProject {
  final String id;
  final String name;
  final String? storeName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DisplaySection> sections;

  SchematicProject({
    String? id,
    required this.name,
    this.storeName,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sections = const [],
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  SchematicProject copyWith({
    String? name,
    String? storeName,
    List<DisplaySection>? sections,
  }) {
    return SchematicProject(
      id: id,
      name: name ?? this.name,
      storeName: storeName ?? this.storeName,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      sections: sections ?? this.sections,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'storeName': storeName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'sections': sections.map((s) => s.toJson()).toList(),
      };

  factory SchematicProject.fromJson(Map<String, dynamic> json) =>
      SchematicProject(
        id: json['id'] as String,
        name: json['name'] as String,
        storeName: json['storeName'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        sections: (json['sections'] as List)
            .map((s) => DisplaySection.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}
