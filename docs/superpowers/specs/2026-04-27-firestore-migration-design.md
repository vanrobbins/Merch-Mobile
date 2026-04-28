# Firestore Migration Design

**Goal:** Replace Drift/SQLite with Cloud Firestore as the data layer, eliminating schema migration pain, data loss on app updates, and build_runner complexity while enabling real-time multi-device sync across coordinator/manager/staff roles.

**Motivation:** `destructiveFallback` wipes the local SQLite database on every schema version bump during development. Since the app is inherently multi-user (role-based: coordinator, manager, staff), Firestore is the natural fit — data lives in the cloud, offline persistence is built in, and real-time sync across devices is a core feature rather than an afterthought.

**Out of scope:** Firebase Storage (photo uploads) is unchanged. Firebase Auth is unchanged.

---

## Data Model

All store-scoped data lives as Firestore subcollections under each store document. This keeps security rules simple (path-based membership check) and matches the existing always-store-scoped query pattern.

```
/stores/{storeId}
  Fields: name, inviteCode, ownerUid, widthFt (nullable), depthFt (nullable), entranceJson (nullable), createdAt

  /memberships/{membershipId}
    Fields: uid, displayName, role (coordinator|manager|staff), status (pending|active|rejected), joinedAt

  /zones/{zoneId}
    Fields: name, colorValue, zoneType, shapePoints (JSON string), positionLocked, posX, posY, width, height, updatedAt

  /fixtures/{fixtureId}
    Fields: zoneId (nullable), fixtureType, posX, posY, rotation, widthFt, depthFt, label, wallAdjacent, planogramId (nullable), planogramIdBack (nullable), mountType, mannequinType, positionX, positionY, updatedAt

  /products/{productId}
    Fields: sku, name, category, imageUrl (nullable), sizesJson, stockQty, colorId (nullable), templateId (nullable), updatedAt

  /planograms/{planogramId}
    Fields: fixtureId, title, season, status (draft|published), slotsJson, publishedAt (nullable), updatedAt

  /proposals/{proposalId}
    Fields: planogramId, proposedByUid, status (pending|approved|rejected), notes, slotChanges, reviewedByUid (nullable), reviewedAt (nullable), updatedAt

  /photos/{photoId}
    Fields: fixtureId, phase (before|after), localPath (nullable), remoteUrl (nullable), uploadStatus, approvalStatus, planogramId (nullable), capturedAt, updatedAt

  /groups/{groupId}
    Fields: name, description, createdByUid, memberStoreIds (List<String>), createdAt

  /brandColors/{colorId}
    Fields: name, hexValue, updatedAt

  /productTemplates/{templateId}
    Fields: name, silhouetteType, updatedAt
```

**ID generation:** Firestore auto-IDs replace UUIDs. The `storeId` field is removed from sub-documents since it is implicit in the collection path.

**Offline persistence:** Enabled once in `main.dart` via `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true)`. Firestore caches all reads locally; writes queue and sync when connectivity returns. This replaces SQLite's offline-first behavior automatically.

---

## Architecture

### Removed

- `lib/core/database/` — entire directory (tables, DAOs, `app_database.dart`, `app_database.g.dart`, schema JSON)
- `build_runner`, `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider` (if only used by Drift) from `pubspec.yaml`
- `build.yaml` drift configuration entries

### Added

**`lib/core/services/firestore_refs.dart`**
Single source of truth for all collection references. All providers import from here.

```dart
class FirestoreRefs {
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
}
```

**`lib/core/models/`** — one plain Dart model class per entity, replacing Drift `DataClass` generated code:

```dart
// Example pattern — same for all models
class ZoneModel {
  const ZoneModel({required this.id, required this.name, ...});

  final String id;
  final String name;
  // ... other fields

  factory ZoneModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ZoneModel(id: doc.id, name: d['name'] as String, ...);
  }

  Map<String, dynamic> toMap() => {'name': name, ...};
}
```

Model files:
- `store_model.dart`
- `membership_model.dart`
- `zone_model.dart`
- `fixture_model.dart`
- `product_model.dart`
- `planogram_model.dart`
- `proposal_model.dart`
- `photo_model.dart`
- `group_model.dart`
- `brand_color_model.dart`
- `product_template_model.dart`

### Modified

**`pubspec.yaml`:** Add `cloud_firestore: ^5.x`, remove Drift packages.

**`main.dart`:** Enable Firestore offline persistence before `runApp`.

**`lib/core/providers/store_provider.dart`:** Replace Drift stream with Firestore snapshot stream for active store and membership.

**Feature providers (7 files):** Each rewritten to use `FirestoreRefs.xyz(storeId).snapshots()` streams and `doc.set()`/`doc.update()`/`doc.delete()` writes in place of DAO methods.

---

## Provider Pattern

```dart
// Before (Drift)
StreamProvider((ref) {
  final db = ref.watch(appDatabaseProvider);
  final storeId = ref.watch(activeStoreIdProvider).value!;
  return db.zonesDao.watchByStore(storeId);
});

// After (Firestore)
StreamProvider((ref) {
  final storeId = ref.watch(activeStoreIdProvider).value!;
  return FirestoreRefs.zones(storeId)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ZoneModel.fromDoc).toList());
});
```

Write operations change from `dao.upsert(companion)` to:
```dart
await FirestoreRefs.zones(storeId).doc(id).set(zone.toMap(), SetOptions(merge: true));
```

---

## Store Join Flow

The invite code is a field on the store document. Joining queries:
```dart
FirebaseFirestore.instance
    .collection('stores')
    .where('inviteCode', isEqualTo: enteredCode)
    .limit(1)
    .get()
```

This requires a single-field index on `stores.inviteCode` — Firebase generates it automatically on first query in development.

---

## Security Rules

File: `firestore.rules` (deployed via `firebase deploy --only firestore:rules`)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper: is the requesting user an active member of this store?
    function isMember(storeId) {
      return exists(/databases/$(database)/documents/stores/$(storeId)/memberships/$(request.auth.uid))
          && get(/databases/$(database)/documents/stores/$(storeId)/memberships/$(request.auth.uid)).data.status == 'active';
    }

    // Helper: what is the user's role in this store?
    function role(storeId) {
      return get(/databases/$(database)/documents/stores/$(storeId)/memberships/$(request.auth.uid)).data.role;
    }

    function isCoordinator(storeId) { return role(storeId) == 'coordinator'; }
    function isManager(storeId)     { return role(storeId) == 'manager'; }
    function isCoordinatorOrManager(storeId) {
      return isCoordinator(storeId) || isManager(storeId);
    }

    // Stores: any authenticated user can read (needed for invite-code join lookup);
    // only the owner can create/update store metadata.
    match /stores/{storeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.ownerUid == request.auth.uid;
      allow update: if request.auth != null && isCoordinator(storeId);
      allow delete: if false; // no store deletion in-app

      // Memberships: user can read their own; coordinator can read/write all.
      match /memberships/{uid} {
        allow read:   if request.auth != null && (request.auth.uid == uid || isMember(storeId));
        allow create: if request.auth != null && request.auth.uid == uid; // self-join request
        allow update: if request.auth != null && isCoordinator(storeId);  // approve/reject/role change
        allow delete: if request.auth != null && (request.auth.uid == uid || isCoordinator(storeId));
      }

      // Zones: members read; coordinator+manager write.
      match /zones/{zoneId} {
        allow read:   if isMember(storeId);
        allow write:  if isCoordinatorOrManager(storeId);
      }

      // Fixtures: members read; coordinator+manager write.
      match /fixtures/{fixtureId} {
        allow read:   if isMember(storeId);
        allow write:  if isCoordinatorOrManager(storeId);
      }

      // Products: members read; coordinator+manager write.
      match /products/{productId} {
        allow read:   if isMember(storeId);
        allow write:  if isCoordinatorOrManager(storeId);
      }

      // Planograms: members read; coordinator+manager write.
      match /planograms/{planogramId} {
        allow read:   if isMember(storeId);
        allow write:  if isCoordinatorOrManager(storeId);
      }

      // Proposals: members read; any member can create; coordinator+manager can update status.
      match /proposals/{proposalId} {
        allow read:   if isMember(storeId);
        allow create: if isMember(storeId);
        allow update: if isCoordinatorOrManager(storeId);
        allow delete: if isCoordinatorOrManager(storeId);
      }

      // Photos: members read; any member can create (staff upload); coordinator+manager update approval.
      match /photos/{photoId} {
        allow read:   if isMember(storeId);
        allow create: if isMember(storeId);
        allow update: if isMember(storeId); // upload status updates by any member
        allow delete: if isCoordinatorOrManager(storeId);
      }

      // Brand colors, product templates, groups: coordinator+manager write; members read.
      match /brandColors/{colorId} {
        allow read:  if isMember(storeId);
        allow write: if isCoordinatorOrManager(storeId);
      }
      match /productTemplates/{templateId} {
        allow read:  if isMember(storeId);
        allow write: if isCoordinatorOrManager(storeId);
      }
      match /groups/{groupId} {
        allow read:  if isMember(storeId);
        allow write: if isCoordinatorOrManager(storeId);
      }
    }
  }
}
```

---

## Security Testing Plan

After deployment, verify the following with the Firebase Emulator Suite (`firebase emulators:start`):

**Authentication boundary:**
- [ ] Unauthenticated user cannot read any store document or subcollection
- [ ] Authenticated user with no membership cannot read zones/fixtures/products

**Membership rules:**
- [ ] Staff user can read zones, fixtures, products, planograms, photos
- [ ] Staff user cannot write to zones, fixtures, products, or planograms
- [ ] Staff user can create a proposal and a photo doc
- [ ] Staff user cannot approve/reject a proposal (update status field)
- [ ] Staff user cannot delete a photo doc

**Coordinator rules:**
- [ ] Coordinator can update store metadata (dimensions, entrance)
- [ ] Coordinator can approve/reject a membership (update status)
- [ ] Coordinator can delete a zone, fixture, product
- [ ] Coordinator can approve/reject a proposal

**Manager rules:**
- [ ] Manager can write zones, fixtures, products (same as coordinator)
- [ ] Manager cannot update store metadata or approve memberships (coordinator-only)

**Cross-store isolation:**
- [ ] Active member of Store A cannot read any subcollection of Store B
- [ ] User with pending (not active) membership cannot read store data

**Invite code:**
- [ ] Any authenticated user can query stores by inviteCode (needed for join flow)
- [ ] Querying stores does NOT expose subcollection data

Each test case should be a unit test in `test/security/firestore_rules_test.dart` using the `fake_cloud_firestore` or Firebase Emulator test SDK.

---

## Implementation Order

1. Add `cloud_firestore` to `pubspec.yaml`; enable offline persistence in `main.dart`
2. Write `lib/core/services/firestore_refs.dart`
3. Write all 11 model classes in `lib/core/models/`
4. Rewrite `lib/core/providers/store_provider.dart` (store + membership streams)
5. Rewrite `lib/features/store/` screens (create store, join store, members)
6. Rewrite `lib/features/zone_manager/zone_map_provider.dart`
7. Rewrite `lib/features/floor_builder/floor_builder_provider.dart`
8. Rewrite `lib/features/product_catalog/catalog_provider.dart`
9. Rewrite `lib/features/planogram/planogram_provider.dart`
10. Rewrite `lib/features/photo_docs/photo_provider.dart`
11. Rewrite `lib/features/dashboard/dashboard_provider.dart`
12. Delete `lib/core/database/`, remove Drift packages, clean `pubspec.yaml`
13. Write and deploy `firestore.rules`
14. Run security test suite against Firebase Emulator
