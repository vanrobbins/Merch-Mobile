import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/brand_color.dart';
import '../models/product.dart';
import 'firestore_refs.dart';

const _uuid = Uuid();

/// Seeds defaults only if the store's `defaultsSeeded` flag is not yet set.
/// Once seeded, the flag is written to the store doc so deleting colors won't re-trigger.
Future<void> maybeSeedDefaultStoreData(String storeId) async {
  final storeDoc = await FirestoreRefs.store(storeId).get();
  final alreadySeeded = (storeDoc.data()?['defaultsSeeded'] as bool?) ?? false;
  if (alreadySeeded) return;
  await seedDefaultStoreData(storeId);
  await FirestoreRefs.store(storeId).set(
    {'defaultsSeeded': true},
    SetOptions(merge: true),
  );
}

/// Seeds 5 default brand colors + 20 default products for a new store.
/// Safe to call on every store creation — uses set with merge: false (first time only).
Future<void> seedDefaultStoreData(String storeId) async {
  final now = DateTime.now();

  // 5 default colors
  const colorDefs = [
    ('white',  'White',  '#FFFFFF'),
    ('black',  'Black',  '#1A1917'),
    ('navy',   'Navy',   '#1B2A4A'),
    ('grey',   'Grey',   '#9E9890'),
    ('khaki',  'Khaki',  '#C8B89A'),
  ];

  final colorIds = <String, String>{};
  final batch = FirebaseFirestore.instance.batch();

  for (final (key, name, hex) in colorDefs) {
    final colorId = '${storeId}_color_$key';
    colorIds[key] = colorId;
    final color = BrandColor(
      id: colorId,
      name: name,
      hexValue: hex,
      updatedAt: now,
    );
    batch.set(FirestoreRefs.brandColors(storeId).doc(colorId), color.toFirestore());
  }

  // 20 default products: (sku, name, category, templateId, colorKey, price)
  const productDefs = [
    // Tops
    ('MVS-WH01', 'Metal Vent SS White',    'Tops',        'builtin_shirt_ss', 'white',  29.99),
    ('MVS-BK01', 'Metal Vent SS Black',    'Tops',        'builtin_shirt_ss', 'black',  29.99),
    ('MVS-NV01', 'Metal Vent SS Navy',     'Tops',        'builtin_shirt_ss', 'navy',   29.99),
    ('TK-GY01',  'Tank Top Grey',          'Tops',        'builtin_tank_top', 'grey',   19.99),
    // Bottoms
    ('SC-KH01',  'Slim Chino Khaki',       'Bottoms',     'builtin_pant',     'khaki',  49.99),
    ('SC-NV01',  'Slim Chino Navy',        'Bottoms',     'builtin_pant',     'navy',   49.99),
    ('SC-BK01',  'Slim Chino Black',       'Bottoms',     'builtin_pant',     'black',  49.99),
    ('SC-GY01',  'Slim Chino Grey',        'Bottoms',     'builtin_pant',     'grey',   49.99),
    // Outerwear
    ('JK-NV01',  'Classic Jacket Navy',    'Outerwear',   'builtin_jacket',   'navy',   89.99),
    ('JK-BK01',  'Classic Jacket Black',   'Outerwear',   'builtin_jacket',   'black',  89.99),
    // Accessories
    ('BG-KH01',  'Canvas Bag Khaki',       'Accessories', 'builtin_bag',      'khaki',  39.99),
    ('BG-BK01',  'Canvas Bag Black',       'Accessories', 'builtin_bag',      'black',  39.99),
    ('HT-WH01',  'Baseball Cap White',     'Accessories', 'builtin_hat',      'white',  24.99),
    ('HT-NV01',  'Baseball Cap Navy',      'Accessories', 'builtin_hat',      'navy',   24.99),
    // Dresses
    ('DR-WH01',  'Summer Dress White',     'Tops',        'builtin_dress',    'white',  59.99),
    ('DR-BK01',  'Summer Dress Black',     'Tops',        'builtin_dress',    'black',  59.99),
    ('DR-KH01',  'Summer Dress Khaki',     'Tops',        'builtin_dress',    'khaki',  59.99),
    // Shorts
    ('SH-KH01',  'Casual Short Khaki',     'Bottoms',     'builtin_short',    'khaki',  34.99),
    ('SH-NV01',  'Casual Short Navy',      'Bottoms',     'builtin_short',    'navy',   34.99),
    ('SH-WH01',  'Casual Short White',     'Bottoms',     'builtin_short',    'white',  34.99),
  ];

  for (final (sku, name, category, templateId, colorKey, price) in productDefs) {
    final product = Product(
      id: _uuid.v4(),
      sku: sku,
      name: name,
      category: category,
      stockQty: 0,
      updatedAt: now,
      templateId: templateId,
      colorId: colorIds[colorKey],
      price: price,
    );
    batch.set(
      FirestoreRefs.products(storeId).doc(product.id),
      product.toFirestore(),
    );
  }

  await batch.commit();
}
