import 'package:uuid/uuid.dart';
import 'color_variant.dart';
import 'garment_type.dart';

class GarmentItem {
  final String id;
  final String name;
  final GarmentType type;
  final List<ColorVariant> colorways;
  final bool isFeatured; // highlighted with callout box

  GarmentItem({
    String? id,
    required this.name,
    required this.type,
    required this.colorways,
    this.isFeatured = false,
  }) : id = id ?? const Uuid().v4();

  GarmentItem copyWith({
    String? name,
    GarmentType? type,
    List<ColorVariant>? colorways,
    bool? isFeatured,
  }) {
    return GarmentItem(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      colorways: colorways ?? this.colorways,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'colorways': colorways.map((c) => c.toJson()).toList(),
        'isFeatured': isFeatured,
      };

  factory GarmentItem.fromJson(Map<String, dynamic> json) => GarmentItem(
        id: json['id'] as String,
        name: json['name'] as String,
        type: GarmentType.values.byName(json['type'] as String),
        colorways: (json['colorways'] as List)
            .map((c) => ColorVariant.fromJson(c as Map<String, dynamic>))
            .toList(),
        isFeatured: json['isFeatured'] as bool? ?? false,
      );
}
