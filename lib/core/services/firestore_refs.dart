import 'package:cloud_firestore/cloud_firestore.dart';

/// Typed Firestore collection references — single source of truth for all paths.
class FirestoreRefs {
  FirestoreRefs._();
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> stores() =>
      _db.collection('stores');

  static DocumentReference<Map<String, dynamic>> store(String storeId) =>
      stores().doc(storeId);

  static CollectionReference<Map<String, dynamic>> memberships(String storeId) =>
      store(storeId).collection('memberships');

  static CollectionReference<Map<String, dynamic>> zones(String storeId) =>
      store(storeId).collection('zones');

  static CollectionReference<Map<String, dynamic>> fixtures(String storeId) =>
      store(storeId).collection('fixtures');

  static CollectionReference<Map<String, dynamic>> products(String storeId) =>
      store(storeId).collection('products');

  static CollectionReference<Map<String, dynamic>> planograms(String storeId) =>
      store(storeId).collection('planograms');

  static CollectionReference<Map<String, dynamic>> proposals(String storeId) =>
      store(storeId).collection('proposals');

  static CollectionReference<Map<String, dynamic>> photos(String storeId) =>
      store(storeId).collection('photos');

  static CollectionReference<Map<String, dynamic>> groups(String storeId) =>
      store(storeId).collection('groups');

  static CollectionReference<Map<String, dynamic>> brandColors(String storeId) =>
      store(storeId).collection('brandColors');

  static CollectionReference<Map<String, dynamic>> productTemplates(String storeId) =>
      store(storeId).collection('productTemplates');

  static DocumentReference<Map<String, dynamic>> userStores(String userId) =>
      _db.collection('userStores').doc(userId);
}
