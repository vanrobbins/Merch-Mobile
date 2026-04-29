import 'package:cloud_firestore/cloud_firestore.dart';

enum LayoutStyle { wallHeavy, mixed, centerGrid }

enum LayoutDensity {
  low, // 4 ft spacing
  medium, // 2 ft spacing
  high; // 1.5 ft spacing

  double get spacingFt {
    switch (this) {
      case LayoutDensity.low:
        return 4.0;
      case LayoutDensity.medium:
        return 2.0;
      case LayoutDensity.high:
        return 1.5;
    }
  }
}

class AutoBuildPreset {
  final String id;
  final String name;
  final String season;
  final LayoutStyle layoutStyle;
  final LayoutDensity density;
  final bool includeMannequins;
  final String createdByUid;
  final DateTime createdAt;

  const AutoBuildPreset({
    required this.id,
    required this.name,
    required this.season,
    required this.layoutStyle,
    required this.density,
    required this.includeMannequins,
    required this.createdByUid,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'season': season,
        'layoutStyle': layoutStyle.name,
        'density': density.name,
        'includeMannequins': includeMannequins,
        'createdByUid': createdByUid,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static AutoBuildPreset fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return AutoBuildPreset(
      id: doc.id,
      name: d['name'] as String,
      season: d['season'] as String? ?? 'Spring',
      layoutStyle: LayoutStyle.values.firstWhere(
        (v) => v.name == d['layoutStyle'],
        orElse: () => LayoutStyle.mixed,
      ),
      density: LayoutDensity.values.firstWhere(
        (v) => v.name == d['density'],
        orElse: () => LayoutDensity.medium,
      ),
      includeMannequins: d['includeMannequins'] as bool? ?? false,
      createdByUid: d['createdByUid'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  String get settingsSummary {
    final styleLabel = switch (layoutStyle) {
      LayoutStyle.wallHeavy => 'Wall-Heavy',
      LayoutStyle.mixed => 'Mixed',
      LayoutStyle.centerGrid => 'Center Grid',
    };
    final densityLabel = switch (density) {
      LayoutDensity.low => 'Low',
      LayoutDensity.medium => 'Med',
      LayoutDensity.high => 'High',
    };
    final mLabel = includeMannequins ? ' · Mannequins' : '';
    return '$season · $styleLabel · $densityLabel$mLabel';
  }
}
