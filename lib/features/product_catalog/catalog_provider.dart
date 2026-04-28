// ignore_for_file: deprecated_member_use_from_same_package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/models/brand_color.dart';
import '../../core/models/product.dart';
import '../../core/models/product_template.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';

part 'catalog_provider.g.dart';

@riverpod
Stream<List<Product>> catalogProducts(CatalogProductsRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value([]);
  return FirestoreRefs.products(storeId)
      .snapshots()
      .map((s) => s.docs.map(ProductFirestore.fromDoc).toList());
}

@riverpod
Stream<List<BrandColor>> brandColors(BrandColorsRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value([]);
  return FirestoreRefs.brandColors(storeId)
      .snapshots()
      .map((s) => s.docs.map(BrandColor.fromDoc).toList());
}

@riverpod
Stream<List<ProductTemplate>> productTemplates(ProductTemplatesRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value([]);
  return FirestoreRefs.productTemplates(storeId)
      .snapshots()
      .map((s) => s.docs.map(ProductTemplate.fromDoc).toList());
}

@riverpod
class CatalogSearch extends _$CatalogSearch {
  @override
  String build() => '';
  void update(String query) => state = query;
}

// --- Write helpers (called from screens) ---

Future<void> upsertProduct(String storeId, Product product) async {
  await FirestoreRefs.products(storeId)
      .doc(product.id)
      .set(product.toFirestore(), SetOptions(merge: true));
}

Future<void> deleteProduct(String storeId, String productId) async {
  await FirestoreRefs.products(storeId).doc(productId).delete();
}

Future<void> upsertBrandColor(String storeId, BrandColor color) async {
  await FirestoreRefs.brandColors(storeId)
      .doc(color.id)
      .set(color.toFirestore(), SetOptions(merge: true));
}

Future<void> deleteBrandColor(String storeId, String colorId) async {
  await FirestoreRefs.brandColors(storeId).doc(colorId).delete();
}

Future<void> upsertProductTemplate(
    String storeId, ProductTemplate template) async {
  await FirestoreRefs.productTemplates(storeId)
      .doc(template.id)
      .set(template.toFirestore(), SetOptions(merge: true));
}

Future<void> deleteProductTemplate(
    String storeId, String templateId) async {
  await FirestoreRefs.productTemplates(storeId).doc(templateId).delete();
}
