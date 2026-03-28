import 'package:uuid/uuid.dart';
import 'color_variant.dart';
import 'garment_type.dart';

enum DecorElementType { plant, mannequin, halfMannequin, braMannequin }

extension DecorElementTypeX on DecorElementType {
  String get displayName => switch (this) {
        DecorElementType.plant => 'Plant',
        DecorElementType.mannequin => 'Full Mannequin',
        DecorElementType.halfMannequin => 'Half Mannequin',
        DecorElementType.braMannequin => 'Bra Form',
      };
  String get icon => switch (this) {
        DecorElementType.plant => '🌱',
        DecorElementType.mannequin => '🧍',
        DecorElementType.halfMannequin => '👤',
        DecorElementType.braMannequin => '👙',
      };

  bool get isShelfForm =>
      this == DecorElementType.halfMannequin ||
      this == DecorElementType.braMannequin;
}

/// A decorative element (plant or mannequin form) that can be placed
/// in or beside a display section, optionally placed on a shelf.
class DecorativeElement {
  final String id;
  final DecorElementType type;

  /// For mannequin/half-mannequin: outfit top color.
  final ColorVariant? outfitTopColor;

  /// For full mannequin: outfit bottom color.
  final ColorVariant? outfitBottomColor;

  /// When true, this element renders ON the shelf rather than beside the section.
  final bool onShelf;

  /// Optional label shown below the element.
  final String? label;

  const DecorativeElement({
    required this.id,
    required this.type,
    this.outfitTopColor,
    this.outfitBottomColor,
    this.onShelf = false,
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

  factory DecorativeElement.halfMannequin({
    ColorVariant? topColor,
    String? label,
    bool onShelf = true,
  }) =>
      DecorativeElement(
        id: const Uuid().v4(),
        type: DecorElementType.halfMannequin,
        outfitTopColor: topColor,
        onShelf: onShelf,
        label: label,
      );

  factory DecorativeElement.braMannequin({
    ColorVariant? topColor,
    String? label,
    bool onShelf = true,
  }) =>
      DecorativeElement(
        id: const Uuid().v4(),
        type: DecorElementType.braMannequin,
        outfitTopColor: topColor,
        onShelf: onShelf,
        label: label,
      );

  DecorativeElement copyWith({
    DecorElementType? type,
    ColorVariant? outfitTopColor,
    ColorVariant? outfitBottomColor,
    bool? onShelf,
    String? label,
    bool clearLabel = false,
  }) {
    return DecorativeElement(
      id: id,
      type: type ?? this.type,
      outfitTopColor: outfitTopColor ?? this.outfitTopColor,
      outfitBottomColor: outfitBottomColor ?? this.outfitBottomColor,
      onShelf: onShelf ?? this.onShelf,
      label: clearLabel ? null : (label ?? this.label),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'outfitTopColor': outfitTopColor?.toJson(),
        'outfitBottomColor': outfitBottomColor?.toJson(),
        'onShelf': onShelf,
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
        onShelf: json['onShelf'] as bool? ?? false,
        label: json['label'] as String?,
      );
}
