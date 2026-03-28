import 'package:uuid/uuid.dart';
import 'color_variant.dart';
import 'garment_type.dart';

enum DecorElementType { plant, mannequin }

extension DecorElementTypeX on DecorElementType {
  String get displayName => switch (this) {
        DecorElementType.plant => 'Plant',
        DecorElementType.mannequin => 'Mannequin',
      };
  String get icon => switch (this) {
        DecorElementType.plant => '🌱',
        DecorElementType.mannequin => '🧍',
      };
}

/// A decorative element (plant or standalone mannequin) that can be placed
/// in or beside a display section.
class DecorativeElement {
  final String id;
  final DecorElementType type;

  /// For mannequin: optional outfit items (top color, bottom color).
  final ColorVariant? outfitTopColor;
  final ColorVariant? outfitBottomColor;

  /// Optional label shown below the element.
  final String? label;

  const DecorativeElement({
    required this.id,
    required this.type,
    this.outfitTopColor,
    this.outfitBottomColor,
    this.label,
  });

  factory DecorativeElement.plant({String? label}) => DecorativeElement(
        id: const Uuid().v4(),
        type: DecorElementType.plant,
        label: label,
      );

  factory DecorativeElement.mannequin({
    ColorVariant? topColor,
    ColorVariant? bottomColor,
    String? label,
  }) =>
      DecorativeElement(
        id: const Uuid().v4(),
        type: DecorElementType.mannequin,
        outfitTopColor: topColor,
        outfitBottomColor: bottomColor,
        label: label,
      );

  DecorativeElement copyWith({
    DecorElementType? type,
    ColorVariant? outfitTopColor,
    ColorVariant? outfitBottomColor,
    String? label,
    bool clearLabel = false,
  }) {
    return DecorativeElement(
      id: id,
      type: type ?? this.type,
      outfitTopColor: outfitTopColor ?? this.outfitTopColor,
      outfitBottomColor: outfitBottomColor ?? this.outfitBottomColor,
      label: clearLabel ? null : (label ?? this.label),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'outfitTopColor': outfitTopColor?.toJson(),
        'outfitBottomColor': outfitBottomColor?.toJson(),
        'label': label,
      };

  factory DecorativeElement.fromJson(Map<String, dynamic> json) =>
      DecorativeElement(
        id: json['id'] as String,
        type: DecorElementType.values.byName(json['type'] as String),
        outfitTopColor: json['outfitTopColor'] != null
            ? ColorVariant.fromJson(
                json['outfitTopColor'] as Map<String, dynamic>)
            : null,
        outfitBottomColor: json['outfitBottomColor'] != null
            ? ColorVariant.fromJson(
                json['outfitBottomColor'] as Map<String, dynamic>)
            : null,
        label: json['label'] as String?,
      );
}
