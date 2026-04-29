// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      gender: json['gender'] as String? ?? 'unisex',
      imageUrl: json['imageUrl'] as String? ?? '',
      sizes:
          (json['sizes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      stockQty: (json['stockQty'] as num?)?.toInt() ?? 0,
      colorId: json['colorId'] as String?,
      templateId: json['templateId'] as String?,
      colorNotes: json['colorNotes'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      imagePath: json['imagePath'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'name': instance.name,
      'category': instance.category,
      'gender': instance.gender,
      'imageUrl': instance.imageUrl,
      'sizes': instance.sizes,
      'stockQty': instance.stockQty,
      'colorId': instance.colorId,
      'templateId': instance.templateId,
      'colorNotes': instance.colorNotes,
      'price': instance.price,
      'imagePath': instance.imagePath,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
