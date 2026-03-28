import 'color_variant.dart';

class MannequinItem {
  final String productName;
  final ColorVariant colorVariant;

  const MannequinItem({
    required this.productName,
    required this.colorVariant,
  });

  MannequinItem copyWith({String? productName, ColorVariant? colorVariant}) {
    return MannequinItem(
      productName: productName ?? this.productName,
      colorVariant: colorVariant ?? this.colorVariant,
    );
  }

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'colorVariant': colorVariant.toJson(),
      };

  factory MannequinItem.fromJson(Map<String, dynamic> json) => MannequinItem(
        productName: json['productName'] as String,
        colorVariant: ColorVariant.fromJson(
          json['colorVariant'] as Map<String, dynamic>,
        ),
      );
}

class MannequinLook {
  final List<MannequinItem> items;

  const MannequinLook({this.items = const []});

  MannequinLook copyWith({List<MannequinItem>? items}) {
    return MannequinLook(items: items ?? this.items);
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory MannequinLook.fromJson(Map<String, dynamic> json) => MannequinLook(
        items: (json['items'] as List)
            .map((i) => MannequinItem.fromJson(i as Map<String, dynamic>))
            .toList(),
      );
}
