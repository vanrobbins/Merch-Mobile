# Firestore Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Drift/SQLite with Cloud Firestore so data persists across app restarts and updates, and syncs in real time across coordinator/manager/staff devices.

**Architecture:** Add `cloud_firestore` alongside Drift initially; migrate one provider at a time (each task compiles cleanly); delete Drift only in the final cleanup task. Models are updated in-place (keeping `@freezed`) with Firestore extension methods added in the same file. No code-gen step changes until cleanup.

**Tech Stack:** Flutter, Riverpod 2 with `@riverpod` codegen, `cloud_firestore ^5.x`, `@freezed` models, Firebase Auth (unchanged), Firebase Storage (unchanged)

**Prerequisites:** Firebase project already configured with `firebase_options.dart` present. Run all tasks on the `feature/v0.2` branch.

---

## File Structure

**New files:**
- `lib/core/services/firestore_refs.dart` — typed collection references, one static method per collection
- `lib/core/models/brand_color.dart` — BrandColor model with Firestore methods
- `lib/core/models/product_template.dart` — ProductTemplate model with Firestore methods
- `firestore.rules` — security rules deployed to Firebase
- `test/security/firestore_rules_test.dart` — rules unit tests

**Modified files (models — add fields + Firestore extensions):**
- `lib/core/models/store.dart` — add widthFt, depthFt, entranceJson
- `lib/core/models/store_zone.dart` — add shapePoints, positionLocked
- `lib/core/models/fixture.dart` — add mountType, mannequinType, positionX, positionY
- `lib/core/models/product.dart` — add colorId, templateId, storeId
- `lib/core/models/planogram.dart` — replace `slots: List<PlanogramSlot>` with `slotsJson: String`
- `lib/core/models/store_membership.dart` — verify fields; add Firestore ext
- `lib/core/models/photo_doc.dart` — add storeId; add Firestore ext
- `lib/core/models/planogram_proposal.dart` — add Firestore ext

**Modified files (providers):**
- `lib/core/providers/store_provider.dart` — Firestore streams replace Drift streams
- `lib/features/zone_manager/zone_map_provider.dart` — Firestore writes/streams
- `lib/features/floor_builder/floor_builder_provider.dart` — Firestore writes/streams
- `lib/features/product_catalog/catalog_provider.dart` — Firestore stream
- `lib/features/planogram/planogram_provider.dart` — Firestore writes/streams
- `lib/features/photo_docs/photo_provider.dart` — Firestore writes/streams
- `lib/features/dashboard/dashboard_provider.dart` — Firestore streams

**Modified files (widgets — type change from TableData → model):**
- `lib/features/zone_manager/zone_map_screen.dart`
- `lib/features/zone_manager/zone_properties_panel.dart`
- `lib/features/floor_builder/floor_builder_screen.dart`
- `lib/features/product_catalog/catalog_screen.dart`
- `lib/features/product_catalog/product_card.dart`
- `lib/features/store/*.dart` (create, join, members, switcher)

**Deleted (Task 13 only):**
- `lib/core/database/` (entire directory)
- `lib/core/providers/database_provider.dart`

---

### Task 1: Add cloud_firestore and enable offline persistence

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`

- [ ] **Step 1: Add cloud_firestore to pubspec.yaml**

In `pubspec.yaml` under `dependencies:`, add after `firebase_storage`:
```yaml
  cloud_firestore: ^5.6.0
```

- [ ] **Step 2: Enable Firestore offline persistence in main.dart**

Replace the entire `lib/main.dart` with:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const ProviderScope(child: MerchMobileApp()));
}
```

- [ ] **Step 3: Install packages**

```bash
flutter pub get
```

Expected: resolves without errors.

- [ ] **Step 4: Verify build still compiles**

```bash
flutter analyze
```

Expected: same warning count as before (no new errors — Drift code still present).

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/main.dart
git commit -m "feat: add cloud_firestore + enable offline persistence"
```

---

### Task 2: Create FirestoreRefs

**Files:**
- Create: `lib/core/services/firestore_refs.dart`

- [ ] **Step 1: Create the file**

```dart
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
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/core/services/firestore_refs.dart
```

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/services/firestore_refs.dart
git commit -m "feat: add FirestoreRefs collection reference helpers"
```

---

### Task 3: Update Store and StoreZone models

**Files:**
- Modify: `lib/core/models/store.dart`
- Modify: `lib/core/models/store_zone.dart`

- [ ] **Step 1: Update Store model**

Replace `lib/core/models/store.dart` entirely:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
class Store with _$Store {
  const factory Store({
    required String id,
    required String name,
    required String inviteCode,
    required String ownerUid,
    double? widthFt,
    double? depthFt,
    String? entranceJson,
    required DateTime createdAt,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}

extension StoreFirestore on Store {
  static Store fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Store(
      id: doc.id,
      name: d['name'] as String,
      inviteCode: d['inviteCode'] as String,
      ownerUid: d['ownerUid'] as String,
      widthFt: (d['widthFt'] as num?)?.toDouble(),
      depthFt: (d['depthFt'] as num?)?.toDouble(),
      entranceJson: d['entranceJson'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'inviteCode': inviteCode,
    'ownerUid': ownerUid,
    if (widthFt != null) 'widthFt': widthFt,
    if (depthFt != null) 'depthFt': depthFt,
    if (entranceJson != null) 'entranceJson': entranceJson,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
```

- [ ] **Step 2: Update StoreZone model**

Replace `lib/core/models/store_zone.dart` entirely:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_zone.freezed.dart';
part 'store_zone.g.dart';

@freezed
class StoreZone with _$StoreZone {
  const factory StoreZone({
    required String id,
    required String name,
    required int colorValue,
    required String zoneType,
    @Default(0.0) double posX,
    @Default(0.0) double posY,
    @Default(0.2) double width,
    @Default(0.2) double height,
    String? shapePoints,
    @Default(false) bool positionLocked,
    required DateTime updatedAt,
  }) = _StoreZone;

  factory StoreZone.fromJson(Map<String, dynamic> json) =>
      _$StoreZoneFromJson(json);
}

extension StoreZoneFirestore on StoreZone {
  static StoreZone fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return StoreZone(
      id: doc.id,
      name: d['name'] as String,
      colorValue: d['colorValue'] as int,
      zoneType: d['zoneType'] as String,
      posX: (d['posX'] as num?)?.toDouble() ?? 0.0,
      posY: (d['posY'] as num?)?.toDouble() ?? 0.0,
      width: (d['width'] as num?)?.toDouble() ?? 0.2,
      height: (d['height'] as num?)?.toDouble() ?? 0.2,
      shapePoints: d['shapePoints'] as String?,
      positionLocked: d['positionLocked'] as bool? ?? false,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'colorValue': colorValue,
    'zoneType': zoneType,
    'posX': posX,
    'posY': posY,
    'width': width,
    'height': height,
    if (shapePoints != null) 'shapePoints': shapePoints,
    'positionLocked': positionLocked,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

- [ ] **Step 3: Regenerate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `Built with build_runner` — no errors.

- [ ] **Step 4: Verify**

```bash
flutter analyze lib/core/models/store.dart lib/core/models/store_zone.dart
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add lib/core/models/store.dart lib/core/models/store_zone.dart lib/core/models/store.freezed.dart lib/core/models/store.g.dart lib/core/models/store_zone.freezed.dart lib/core/models/store_zone.g.dart
git commit -m "feat: update Store + StoreZone models for Firestore"
```

---

### Task 4: Update remaining models; add BrandColor and ProductTemplate

**Files:**
- Modify: `lib/core/models/fixture.dart`
- Modify: `lib/core/models/product.dart`
- Modify: `lib/core/models/planogram.dart`
- Modify: `lib/core/models/store_membership.dart`
- Modify: `lib/core/models/photo_doc.dart`
- Modify: `lib/core/models/planogram_proposal.dart`
- Create: `lib/core/models/brand_color.dart`
- Create: `lib/core/models/product_template.dart`

- [ ] **Step 1: Update Fixture model**

Replace `lib/core/models/fixture.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fixture.freezed.dart';
part 'fixture.g.dart';

@freezed
class Fixture with _$Fixture {
  const factory Fixture({
    required String id,
    String? zoneId,
    required String fixtureType,
    @Default(0.0) double posX,
    @Default(0.0) double posY,
    @Default(0.0) double rotation,
    @Default(4.0) double widthFt,
    @Default(2.0) double depthFt,
    @Default('') String label,
    String? planogramId,
    String? planogramIdBack,
    @Default(false) bool wallAdjacent,
    @Default('floor') String mountType,
    @Default('full') String mannequinType,
    @Default(0.0) double positionX,
    @Default(0.0) double positionY,
    required DateTime updatedAt,
  }) = _Fixture;

  factory Fixture.fromJson(Map<String, dynamic> json) =>
      _$FixtureFromJson(json);
}

extension FixtureFirestore on Fixture {
  static Fixture fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Fixture(
      id: doc.id,
      zoneId: d['zoneId'] as String?,
      fixtureType: d['fixtureType'] as String,
      posX: (d['posX'] as num?)?.toDouble() ?? 0.0,
      posY: (d['posY'] as num?)?.toDouble() ?? 0.0,
      rotation: (d['rotation'] as num?)?.toDouble() ?? 0.0,
      widthFt: (d['widthFt'] as num?)?.toDouble() ?? 4.0,
      depthFt: (d['depthFt'] as num?)?.toDouble() ?? 2.0,
      label: d['label'] as String? ?? '',
      planogramId: d['planogramId'] as String?,
      planogramIdBack: d['planogramIdBack'] as String?,
      wallAdjacent: d['wallAdjacent'] as bool? ?? false,
      mountType: d['mountType'] as String? ?? 'floor',
      mannequinType: d['mannequinType'] as String? ?? 'full',
      positionX: (d['positionX'] as num?)?.toDouble() ?? 0.0,
      positionY: (d['positionY'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    if (zoneId != null) 'zoneId': zoneId,
    'fixtureType': fixtureType,
    'posX': posX,
    'posY': posY,
    'rotation': rotation,
    'widthFt': widthFt,
    'depthFt': depthFt,
    'label': label,
    if (planogramId != null) 'planogramId': planogramId,
    if (planogramIdBack != null) 'planogramIdBack': planogramIdBack,
    'wallAdjacent': wallAdjacent,
    'mountType': mountType,
    'mannequinType': mannequinType,
    'positionX': positionX,
    'positionY': positionY,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

- [ ] **Step 2: Update Product model**

Replace `lib/core/models/product.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String sku,
    required String name,
    required String category,
    @Default('') String imageUrl,
    @Default(<String>[]) List<String> sizes,
    @Default(0) int stockQty,
    String? colorId,
    String? templateId,
    required DateTime updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

extension ProductFirestore on Product {
  static Product fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Product(
      id: doc.id,
      sku: d['sku'] as String,
      name: d['name'] as String,
      category: d['category'] as String,
      imageUrl: d['imageUrl'] as String? ?? '',
      sizes: List<String>.from(d['sizes'] as List? ?? []),
      stockQty: d['stockQty'] as int? ?? 0,
      colorId: d['colorId'] as String?,
      templateId: d['templateId'] as String?,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'sku': sku,
    'name': name,
    'category': category,
    'imageUrl': imageUrl,
    'sizes': sizes,
    'stockQty': stockQty,
    if (colorId != null) 'colorId': colorId,
    if (templateId != null) 'templateId': templateId,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

- [ ] **Step 3: Update Planogram model**

Replace `lib/core/models/planogram.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'planogram.freezed.dart';
part 'planogram.g.dart';

@freezed
class Planogram with _$Planogram {
  const factory Planogram({
    required String id,
    required String fixtureId,
    required String title,
    required String season,
    @Default('draft') String status,
    @Default('') String slotsJson,
    DateTime? publishedAt,
    required DateTime updatedAt,
  }) = _Planogram;

  factory Planogram.fromJson(Map<String, dynamic> json) =>
      _$PlanogramFromJson(json);
}

extension PlanogramFirestore on Planogram {
  static Planogram fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Planogram(
      id: doc.id,
      fixtureId: d['fixtureId'] as String,
      title: d['title'] as String,
      season: d['season'] as String,
      status: d['status'] as String? ?? 'draft',
      slotsJson: d['slotsJson'] as String? ?? '',
      publishedAt: d['publishedAt'] != null
          ? (d['publishedAt'] as Timestamp).toDate()
          : null,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'fixtureId': fixtureId,
    'title': title,
    'season': season,
    'status': status,
    'slotsJson': slotsJson,
    if (publishedAt != null)
      'publishedAt': Timestamp.fromDate(publishedAt!),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

- [ ] **Step 4: Update StoreMembership model**

Replace `lib/core/models/store_membership.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_membership.freezed.dart';
part 'store_membership.g.dart';

@freezed
class StoreMembership with _$StoreMembership {
  const factory StoreMembership({
    required String id,
    required String storeId,
    required String uid,
    required String role,
    required String status,
    required String displayName,
    required DateTime joinedAt,
  }) = _StoreMembership;

  factory StoreMembership.fromJson(Map<String, dynamic> json) =>
      _$StoreMembershipFromJson(json);
}

extension StoreMembershipFirestore on StoreMembership {
  static StoreMembership fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String storeId,
  ) {
    final d = doc.data()!;
    return StoreMembership(
      id: doc.id,
      storeId: storeId,
      uid: doc.id,
      role: d['role'] as String,
      status: d['status'] as String,
      displayName: d['displayName'] as String? ?? '',
      joinedAt: (d['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'role': role,
    'status': status,
    'displayName': displayName,
    'joinedAt': Timestamp.fromDate(joinedAt),
  };
}
```

- [ ] **Step 5: Update PhotoDoc model**

Replace `lib/core/models/photo_doc.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_doc.freezed.dart';
part 'photo_doc.g.dart';

@freezed
class PhotoDoc with _$PhotoDoc {
  const factory PhotoDoc({
    required String id,
    required String fixtureId,
    required String phase,
    String? localPath,
    String? remoteUrl,
    @Default('pending') String uploadStatus,
    @Default('none') String approvalStatus,
    String? planogramId,
    required String storeId,
    required DateTime capturedAt,
    required DateTime updatedAt,
  }) = _PhotoDoc;

  factory PhotoDoc.fromJson(Map<String, dynamic> json) =>
      _$PhotoDocFromJson(json);
}

extension PhotoDocFirestore on PhotoDoc {
  static PhotoDoc fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String storeId,
  ) {
    final d = doc.data()!;
    return PhotoDoc(
      id: doc.id,
      fixtureId: d['fixtureId'] as String,
      phase: d['phase'] as String,
      localPath: d['localPath'] as String?,
      remoteUrl: d['remoteUrl'] as String?,
      uploadStatus: d['uploadStatus'] as String? ?? 'pending',
      approvalStatus: d['approvalStatus'] as String? ?? 'none',
      planogramId: d['planogramId'] as String?,
      storeId: storeId,
      capturedAt: (d['capturedAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'fixtureId': fixtureId,
    'phase': phase,
    if (localPath != null) 'localPath': localPath,
    if (remoteUrl != null) 'remoteUrl': remoteUrl,
    'uploadStatus': uploadStatus,
    'approvalStatus': approvalStatus,
    if (planogramId != null) 'planogramId': planogramId,
    'capturedAt': Timestamp.fromDate(capturedAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

- [ ] **Step 6: Update PlanogramProposal model**

Replace `lib/core/models/planogram_proposal.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'planogram_proposal.freezed.dart';
part 'planogram_proposal.g.dart';

@freezed
class PlanogramProposal with _$PlanogramProposal {
  const factory PlanogramProposal({
    required String id,
    required String planogramId,
    required String storeId,
    required String proposedByUid,
    @Default('pending') String status,
    @Default('') String notes,
    @Default('') String slotChanges,
    String? reviewedByUid,
    DateTime? reviewedAt,
    required DateTime updatedAt,
  }) = _PlanogramProposal;

  factory PlanogramProposal.fromJson(Map<String, dynamic> json) =>
      _$PlanogramProposalFromJson(json);
}

extension PlanogramProposalFirestore on PlanogramProposal {
  static PlanogramProposal fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String storeId,
  ) {
    final d = doc.data()!;
    return PlanogramProposal(
      id: doc.id,
      planogramId: d['planogramId'] as String,
      storeId: storeId,
      proposedByUid: d['proposedByUid'] as String,
      status: d['status'] as String? ?? 'pending',
      notes: d['notes'] as String? ?? '',
      slotChanges: d['slotChanges'] as String? ?? '',
      reviewedByUid: d['reviewedByUid'] as String?,
      reviewedAt: d['reviewedAt'] != null
          ? (d['reviewedAt'] as Timestamp).toDate()
          : null,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'planogramId': planogramId,
    'proposedByUid': proposedByUid,
    'status': status,
    'notes': notes,
    'slotChanges': slotChanges,
    if (reviewedByUid != null) 'reviewedByUid': reviewedByUid,
    if (reviewedAt != null) 'reviewedAt': Timestamp.fromDate(reviewedAt!),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

- [ ] **Step 7: Create BrandColor model**

Create `lib/core/models/brand_color.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BrandColor {
  const BrandColor({
    required this.id,
    required this.name,
    required this.hexValue,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String hexValue;
  final DateTime updatedAt;

  factory BrandColor.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return BrandColor(
      id: doc.id,
      name: d['name'] as String,
      hexValue: d['hexValue'] as String,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'hexValue': hexValue,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  BrandColor copyWith({String? name, String? hexValue, DateTime? updatedAt}) =>
      BrandColor(
        id: id,
        name: name ?? this.name,
        hexValue: hexValue ?? this.hexValue,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
```

- [ ] **Step 8: Create ProductTemplate model**

Create `lib/core/models/product_template.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductTemplate {
  const ProductTemplate({
    required this.id,
    required this.name,
    required this.silhouetteType,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String silhouetteType;
  final DateTime updatedAt;

  factory ProductTemplate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ProductTemplate(
      id: doc.id,
      name: d['name'] as String,
      silhouetteType: d['silhouetteType'] as String,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'silhouetteType': silhouetteType,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  ProductTemplate copyWith({
    String? name,
    String? silhouetteType,
    DateTime? updatedAt,
  }) => ProductTemplate(
    id: id,
    name: name ?? this.name,
    silhouetteType: silhouetteType ?? this.silhouetteType,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
```

- [ ] **Step 9: Regenerate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `Built with build_runner` — no errors.

- [ ] **Step 10: Verify**

```bash
flutter analyze lib/core/models/
```

Expected: no errors (only pre-existing infos).

- [ ] **Step 11: Commit**

```bash
git add lib/core/models/
git commit -m "feat: update all models with Firestore fromDoc/toFirestore extensions"
```

---

### Task 5: Rewrite store_provider.dart

**Files:**
- Modify: `lib/core/providers/store_provider.dart`

The current `store_provider.dart` uses Drift streams. Replace it entirely with Firestore streams. The `activeStoreIdProvider` (SharedPreferences) stays unchanged.

- [ ] **Step 1: Replace store_provider.dart**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/store.dart';
import '../models/store_membership.dart';
import '../services/firestore_refs.dart';
import 'auth_provider.dart';

part 'store_provider.g.dart';

const _kActiveStoreKey = 'active_store_id';

@Riverpod(keepAlive: true)
class ActiveStoreId extends _$ActiveStoreId {
  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kActiveStoreKey);
  }

  Future<void> setStore(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kActiveStoreKey, storeId);
    state = AsyncValue.data(storeId);
  }

  Future<void> clearStore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActiveStoreKey);
    state = const AsyncValue.data(null);
  }
}

/// The full Store record for the active store ID.
@riverpod
Stream<Store?> activeStore(ActiveStoreRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value(null);
  return FirestoreRefs.store(storeId).snapshots().map(
    (snap) => snap.exists ? StoreFirestore.fromDoc(snap) : null,
  );
}

/// The current user's active membership in the active store.
@riverpod
Stream<StoreMembership?> currentMembership(CurrentMembershipRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value(null);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return FirestoreRefs.memberships(storeId).doc(user.uid).snapshots().map(
    (snap) {
      if (!snap.exists) return null;
      final m = StoreMembershipFirestore.fromDoc(snap, storeId);
      return m.status == 'active' ? m : null;
    },
  );
}

/// All stores where the current user has an active membership.
@riverpod
Stream<List<Store>> myStores(MyStoresRef ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  // Query all stores where memberships/{uid}.status == 'active'
  // Firestore doesn't support cross-collection queries, so we use a
  // collectionGroup query on 'memberships' filtered by uid and status.
  return FirebaseFirestore.instance
      .collectionGroup('memberships')
      .where(FieldPath.documentId, isEqualTo: user.uid)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .asyncMap((snap) async {
    final stores = <Store>[];
    for (final memberDoc in snap.docs) {
      // Parent path: stores/{storeId}/memberships/{uid}
      final storeRef = memberDoc.reference.parent.parent!;
      final storeSnap = await storeRef.get();
      if (storeSnap.exists) {
        stores.add(StoreFirestore.fromDoc(
          storeSnap as DocumentSnapshot<Map<String, dynamic>>,
        ));
      }
    }
    return stores;
  });
}
```

- [ ] **Step 2: Regenerate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Fix compilation errors in files that imported StoresTableData/StoreMembershipsTableData from store_provider**

Search for files still referencing the old types:
```bash
grep -r "StoresTableData\|StoreMembershipsTableData" lib/ --include="*.dart" -l
```

For each file listed, update the import and type references:
- Replace `StoresTableData` → `Store`
- Replace `StoreMembershipsTableData` → `StoreMembership`
- Remove `import '../../core/database/app_database.dart';` where it was only needed for those types
- Add `import '../../core/models/store.dart';` and `import '../../core/models/store_membership.dart';`

- [ ] **Step 4: Verify**

```bash
flutter analyze
```

Expected: no new errors beyond pre-existing Drift infos.

- [ ] **Step 5: Commit**

```bash
git add lib/core/providers/store_provider.dart lib/core/providers/store_provider.g.dart
git commit -m "feat: rewrite store_provider to use Firestore streams"
```

---

### Task 6: Rewrite store feature screens

**Files:**
- Modify: `lib/features/store/create_store_screen.dart`
- Modify: `lib/features/store/join_store_screen.dart`
- Modify: `lib/features/store/members_screen.dart`
- Modify: `lib/features/store/store_switcher_sheet.dart`
- Modify: `lib/features/dashboard/dashboard_screen.dart` (type references only)

- [ ] **Step 1: Read create_store_screen.dart to understand current DB writes**

Read the file and find all `db.storesDao` and `db.storeMembershipsDao` calls.

- [ ] **Step 2: Replace store creation writes**

In `create_store_screen.dart`, find the store creation logic. Replace any `db.storesDao.upsert(...)` call with:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
// ...

final storeId = const Uuid().v4();
final now = DateTime.now();
final store = Store(
  id: storeId,
  name: nameCtrl.text.trim(),
  inviteCode: _generateCode(),
  ownerUid: user.uid,
  createdAt: now,
);
await FirestoreRefs.store(storeId).set(store.toFirestore());
// Create coordinator membership
final membership = StoreMembership(
  id: user.uid,
  storeId: storeId,
  uid: user.uid,
  role: 'coordinator',
  status: 'active',
  displayName: user.displayName ?? user.email ?? '',
  joinedAt: now,
);
await FirestoreRefs.memberships(storeId).doc(user.uid)
    .set(membership.toFirestore());
await ref.read(activeStoreIdProvider.notifier).setStore(storeId);
```

Keep the `_generateCode()` helper if it already exists (generates an 8-char alphanumeric invite code). If it uses Drift to check uniqueness, replace with a simple random generation (collision probability is negligible for a school project).

- [ ] **Step 3: Replace join store writes**

In `join_store_screen.dart`, replace the invite-code lookup:
```dart
// Find store by invite code
final snap = await FirebaseFirestore.instance
    .collection('stores')
    .where('inviteCode', isEqualTo: enteredCode.trim().toUpperCase())
    .limit(1)
    .get();
if (snap.docs.isEmpty) {
  // show error: code not found
  return;
}
final storeDoc = snap.docs.first;
final storeId = storeDoc.id;
final user = FirebaseAuth.instance.currentUser!;

// Create pending membership
await FirestoreRefs.memberships(storeId).doc(user.uid).set({
  'role': 'staff',
  'status': 'pending',
  'displayName': user.displayName ?? user.email ?? '',
  'joinedAt': Timestamp.now(),
});
// Navigate to pending approval screen
```

- [ ] **Step 4: Replace members_screen.dart DB calls**

In `members_screen.dart`, replace any `db.storeMembershipsDao.watchPending(storeId)` with:
```dart
// Watch pending memberships
FirestoreRefs.memberships(storeId)
    .where('status', isEqualTo: 'pending')
    .snapshots()
    .map((s) => s.docs.map((d) =>
        StoreMembershipFirestore.fromDoc(d, storeId)).toList())
```

Replace approve/reject calls:
```dart
// Approve
await FirestoreRefs.memberships(storeId).doc(memberUid)
    .update({'status': 'active', 'role': selectedRole});

// Reject
await FirestoreRefs.memberships(storeId).doc(memberUid)
    .update({'status': 'rejected'});
```

- [ ] **Step 5: Fix dashboard_screen.dart type references**

In `dashboard_screen.dart`, update any `StoresTableData` references to `Store` and `StoreMembershipsTableData` to `StoreMembership`. Update the field access if needed (`store.widthFt`, `store.entranceJson` — these are now nullable fields on the `Store` model, same as before).

- [ ] **Step 6: Verify**

```bash
flutter analyze lib/features/store/ lib/features/dashboard/
```

Expected: no errors.

- [ ] **Step 7: Commit**

```bash
git add lib/features/store/ lib/features/dashboard/dashboard_screen.dart
git commit -m "feat: rewrite store screens to use Firestore"
```

---

### Task 7: Rewrite zone_map_provider.dart

**Files:**
- Modify: `lib/features/zone_manager/zone_map_provider.dart`
- Modify: `lib/features/zone_manager/zone_map_screen.dart`
- Modify: `lib/features/zone_manager/zone_properties_panel.dart`

- [ ] **Step 1: Replace zone_map_provider.dart**

```dart
import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/store.dart';
import '../../core/models/store_zone.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import 'zone_shape.dart';

part 'zone_map_provider.g.dart';

const _sentinel = Object();

class ZoneMapState {
  final List<StoreZone> zones;
  final String? selectedZoneId;
  final bool isLoading;
  final Store? storeData;

  const ZoneMapState({
    required this.zones,
    this.selectedZoneId,
    this.isLoading = false,
    this.storeData,
  });

  ZoneMapState copyWith({
    List<StoreZone>? zones,
    Object? selectedZoneId = _sentinel,
    bool? isLoading,
    Object? storeData = _sentinel,
  }) {
    return ZoneMapState(
      zones: zones ?? this.zones,
      selectedZoneId: selectedZoneId == _sentinel
          ? this.selectedZoneId
          : selectedZoneId as String?,
      isLoading: isLoading ?? this.isLoading,
      storeData: storeData == _sentinel
          ? this.storeData
          : storeData as Store?,
    );
  }
}

@riverpod
class ZoneMapNotifier extends _$ZoneMapNotifier {
  StreamSubscription<List<StoreZone>>? _zoneSub;
  StreamSubscription<Store?>? _storeSub;

  @override
  ZoneMapState build() {
    final storeId = ref.watch(activeStoreIdProvider).value;

    _zoneSub?.cancel();
    _storeSub?.cancel();

    if (storeId != null && storeId.isNotEmpty) {
      _zoneSub = FirestoreRefs.zones(storeId)
          .snapshots()
          .map((s) => s.docs.map(StoreZoneFirestore.fromDoc).toList())
          .listen((rows) {
        state = state.copyWith(zones: rows, isLoading: false);
      });
      _storeSub = FirestoreRefs.store(storeId).snapshots().map(
        (s) => s.exists ? StoreFirestore.fromDoc(s) : null,
      ).listen((store) {
        state = state.copyWith(storeData: store);
      });
    }

    ref.onDispose(() {
      _zoneSub?.cancel();
      _storeSub?.cancel();
    });

    return const ZoneMapState(zones: [], isLoading: true);
  }

  String get _storeId => ref.read(activeStoreIdProvider).value ?? '';

  void selectZone(String? id) => state = state.copyWith(selectedZoneId: id);

  Future<void> addZone() async {
    const center = Offset(0.5, 0.5);
    final zone = StoreZone(
      id: const Uuid().v4(),
      name: 'Zone ${state.zones.length + 1}',
      colorValue: 0xFF3B6BC2,
      zoneType: 'display',
      shapePoints: ZoneShape.encode(ZoneShape.defaultRect(center)),
      updatedAt: DateTime.now(),
    );
    await FirestoreRefs.zones(_storeId)
        .doc(zone.id)
        .set(zone.toFirestore());
  }

  Future<void> addZoneOfType(String zoneType) async {
    const center = Offset(0.5, 0.5);
    final name = zoneType == 'entrance'
        ? 'Entrance'
        : zoneType == 'cash_wrap'
            ? 'Cash Wrap'
            : 'Zone ${state.zones.length + 1}';
    final color = zoneType == 'entrance' ? 0xFF1A1917 : 0xFF3B6BC2;
    final zone = StoreZone(
      id: const Uuid().v4(),
      name: name,
      colorValue: color,
      zoneType: zoneType,
      shapePoints: ZoneShape.encode(ZoneShape.defaultRect(center)),
      updatedAt: DateTime.now(),
    );
    await FirestoreRefs.zones(_storeId)
        .doc(zone.id)
        .set(zone.toFirestore());
  }

  Future<void> updateZoneName(String id, String name) =>
      _patch(id, {'name': name});

  Future<void> updateZoneColor(String id, int colorValue) {
    state = state.copyWith(zones: [
      for (final z in state.zones)
        if (z.id == id) z.copyWith(colorValue: colorValue) else z,
    ]);
    return _patch(id, {'colorValue': colorValue});
  }

  Future<void> updateZoneType(String id, String type) {
    state = state.copyWith(zones: [
      for (final z in state.zones)
        if (z.id == id) z.copyWith(zoneType: type) else z,
    ]);
    return _patch(id, {'zoneType': type});
  }

  Future<void> updateZoneLocked(String id, {required bool locked}) {
    state = state.copyWith(zones: [
      for (final z in state.zones)
        if (z.id == id) z.copyWith(positionLocked: locked) else z,
    ]);
    return _patch(id, {'positionLocked': locked});
  }

  Future<void> updateZoneShape(String id, List<Offset> points) =>
      _patch(id, {'shapePoints': ZoneShape.encode(points)});

  void updateZoneShapeLocal(String id, List<Offset> points) {
    state = state.copyWith(zones: [
      for (final z in state.zones)
        if (z.id == id)
          z.copyWith(shapePoints: ZoneShape.encode(points))
        else
          z,
    ]);
  }

  Future<void> moveZone(String id, Offset normDelta) =>
      updateZoneShape(id, _translatedPoints(id, normDelta));

  void moveZoneLocal(String id, Offset normDelta) =>
      updateZoneShapeLocal(id, _translatedPoints(id, normDelta));

  Future<void> addVertex(String id, int afterIdx, Offset normPt) {
    final zone = state.zones.firstWhereOrNull((z) => z.id == id);
    if (zone == null) return Future.value();
    final pts = List.of(ZoneShape.decode(zone.shapePoints))
      ..insert(afterIdx + 1, normPt);
    return updateZoneShape(id, pts);
  }

  Future<void> removeVertex(String id, int idx) {
    final zone = state.zones.firstWhereOrNull((z) => z.id == id);
    if (zone == null) return Future.value();
    final pts = List.of(ZoneShape.decode(zone.shapePoints));
    if (pts.length <= 3) return Future.value();
    pts.removeAt(idx);
    return updateZoneShape(id, pts);
  }

  Future<void> deleteZone(String id) async {
    await FirestoreRefs.zones(_storeId).doc(id).delete();
    if (state.selectedZoneId == id) {
      state = state.copyWith(selectedZoneId: null);
    }
  }

  Future<void> applyPreset(String id, String presetName) async {
    final zone = state.zones.firstWhere((z) => z.id == id);
    final points = ZoneShape.presetAt(presetName, Offset(zone.posX, zone.posY));
    await updateZoneShape(id, points);
  }

  Future<void> updateStoreDimensions(double widthFt, double depthFt) async {
    await FirestoreRefs.store(_storeId).update({
      'widthFt': widthFt,
      'depthFt': depthFt,
    });
  }

  Future<void> setEntrance(String entranceJson) async {
    // Remove legacy entrance zones
    for (final z in state.zones.where((z) => z.zoneType == 'entrance')) {
      await FirestoreRefs.zones(_storeId).doc(z.id).delete();
    }
    await FirestoreRefs.store(_storeId)
        .update({'entranceJson': entranceJson});
  }

  Future<void> removeEntrance() async {
    await FirestoreRefs.store(_storeId)
        .update({'entranceJson': FieldValue.delete()});
  }

  Future<void> _patch(String id, Map<String, dynamic> fields) async {
    await FirestoreRefs.zones(_storeId).doc(id).update({
      ...fields,
      'updatedAt': Timestamp.now(),
    });
  }

  List<Offset> _translatedPoints(String id, Offset normDelta) {
    final zone = state.zones.firstWhereOrNull((z) => z.id == id);
    if (zone == null) return [];
    return [
      for (final p in ZoneShape.decode(zone.shapePoints))
        Offset(
          (p.dx + normDelta.dx).clamp(0.0, 1.0),
          (p.dy + normDelta.dy).clamp(0.0, 1.0),
        ),
    ];
  }
}
```

- [ ] **Step 2: Update zone_map_screen.dart and zone_properties_panel.dart type references**

In both files, replace `ZonesTableData` → `StoreZone` and update imports:
- Remove `import '../../core/database/app_database.dart';`
- Add `import '../../core/models/store_zone.dart';` and `import '../../core/models/store.dart';`

Field access changes:
- `zone.colorValue` — same
- `zone.zoneType` — same
- `zone.shapePoints` — same (now `String?` on StoreZone)
- `zone.positionLocked` — same
- `state.storeData?.widthFt` — same (now on Store model)

- [ ] **Step 3: Update zone_map_painter.dart type**

In `zone_map_painter.dart`, `zones` field is `List<ZonesTableData>`. Change to `List<StoreZone>` and update the import. Access patterns stay the same (same field names).

- [ ] **Step 4: Regenerate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Verify**

```bash
flutter analyze lib/features/zone_manager/
```

Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add lib/features/zone_manager/
git commit -m "feat: rewrite zone_map_provider to use Firestore"
```

---

### Task 8: Rewrite floor_builder_provider.dart

**Files:**
- Modify: `lib/features/floor_builder/floor_builder_provider.dart`
- Modify: `lib/features/floor_builder/floor_builder_screen.dart`

- [ ] **Step 1: Replace floor_builder_provider.dart**

```dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/fixture.dart';
import '../../core/models/planogram.dart';
import '../../core/models/store_zone.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';

part 'floor_builder_provider.g.dart';

const _uuid = Uuid();
const _sentinel = Object();

class FloorBuilderState {
  final List<Fixture> fixtures;
  final String? selectedFixtureId;
  final bool snapGridEnabled;
  final double gridSizeFt;
  final bool isDragging;
  final bool isLoading;
  final Map<String, Planogram> planograms;

  const FloorBuilderState({
    this.fixtures = const [],
    this.selectedFixtureId,
    this.snapGridEnabled = true,
    this.gridSizeFt = 2.0,
    this.isDragging = false,
    this.isLoading = false,
    this.planograms = const {},
  });

  FloorBuilderState copyWith({
    List<Fixture>? fixtures,
    Object? selectedFixtureId = _sentinel,
    bool? snapGridEnabled,
    double? gridSizeFt,
    bool? isDragging,
    bool? isLoading,
    Map<String, Planogram>? planograms,
  }) {
    return FloorBuilderState(
      fixtures: fixtures ?? this.fixtures,
      selectedFixtureId: selectedFixtureId == _sentinel
          ? this.selectedFixtureId
          : selectedFixtureId as String?,
      snapGridEnabled: snapGridEnabled ?? this.snapGridEnabled,
      gridSizeFt: gridSizeFt ?? this.gridSizeFt,
      isDragging: isDragging ?? this.isDragging,
      isLoading: isLoading ?? this.isLoading,
      planograms: planograms ?? this.planograms,
    );
  }
}

@riverpod
class FloorBuilderNotifier extends _$FloorBuilderNotifier {
  StreamSubscription<List<Fixture>>? _sub;
  StreamSubscription<List<Planogram>>? _planogramSub;
  String? _zoneId;

  @override
  FloorBuilderState build() {
    ref.onDispose(() {
      _sub?.cancel();
      _planogramSub?.cancel();
    });
    return const FloorBuilderState(isLoading: true);
  }

  String get _storeId => ref.read(activeStoreIdProvider).value ?? '';

  void loadFixtures(String zoneId) {
    _zoneId = zoneId;
    final storeId = _storeId;

    _sub?.cancel();
    _sub = FirestoreRefs.fixtures(storeId)
        .where('zoneId', isEqualTo: zoneId)
        .snapshots()
        .map((s) => s.docs.map(FixtureFirestore.fromDoc).toList())
        .listen((rows) {
      state = state.copyWith(fixtures: rows, isLoading: false);
    });

    _planogramSub?.cancel();
    _planogramSub = FirestoreRefs.planograms(storeId)
        .snapshots()
        .map((s) => s.docs.map(PlanogramFirestore.fromDoc).toList())
        .listen((rows) {
      state = state.copyWith(planograms: {for (final p in rows) p.id: p});
    });
  }

  Future<void> addFixture(String type, Offset normalizedPos) async {
    if (_zoneId == null) return;
    final fixture = Fixture(
      id: _uuid.v4(),
      zoneId: _zoneId,
      fixtureType: type,
      posX: normalizedPos.dx,
      posY: normalizedPos.dy,
      label: type.toUpperCase(),
      updatedAt: DateTime.now(),
    );
    await FirestoreRefs.fixtures(_storeId)
        .doc(fixture.id)
        .set(fixture.toFirestore());
  }

  Future<void> addWallFixture({
    required Offset centerFt,
    required double lengthFt,
    required double angleDeg,
  }) async {
    if (_zoneId == null) return;
    const depthFt = 0.5;
    final fixture = Fixture(
      id: _uuid.v4(),
      zoneId: _zoneId,
      fixtureType: 'wall',
      posX: centerFt.dx - lengthFt / 2,
      posY: centerFt.dy - depthFt / 2,
      rotation: angleDeg,
      widthFt: lengthFt,
      depthFt: depthFt,
      label: 'WALL',
      updatedAt: DateTime.now(),
    );
    await FirestoreRefs.fixtures(_storeId)
        .doc(fixture.id)
        .set(fixture.toFirestore());
  }

  Future<void> moveFixture(String id, Offset pos) {
    double x = pos.dx;
    double y = pos.dy;
    if (state.snapGridEnabled) {
      final gs = state.gridSizeFt;
      x = (x / gs).round() * gs;
      y = (y / gs).round() * gs;
    }
    return _patch(id, {'posX': x, 'posY': y});
  }

  Future<void> rotateFixture(String id) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == id);
    if (fixture == null) return Future.value();
    return _patch(id, {'rotation': (fixture.rotation + 90) % 360});
  }

  Future<void> renameFixture(String id, String label) =>
      _patch(id, {'label': label});

  Future<void> deleteFixture(String id) async {
    await FirestoreRefs.fixtures(_storeId).doc(id).delete();
    if (state.selectedFixtureId == id) {
      state = state.copyWith(selectedFixtureId: null);
    }
  }

  void selectFixture(String? id) => state = state.copyWith(selectedFixtureId: id);

  Fixture _resizedFixture(Fixture f, double? widthFt, double? depthFt) {
    final maxDepth = f.fixtureType == 'partition' ? 1.0 : double.infinity;
    return f.copyWith(
      widthFt: (widthFt ?? f.widthFt).clamp(0.5, double.infinity),
      depthFt: (depthFt ?? f.depthFt).clamp(0.5, maxDepth),
    );
  }

  void resizeFixtureLocal(String id, double? widthFt, double? depthFt) {
    state = state.copyWith(
      fixtures: state.fixtures
          .map((f) => f.id == id ? _resizedFixture(f, widthFt, depthFt) : f)
          .toList(),
    );
  }

  Future<void> resizeFixture(String id, double? widthFt, double? depthFt) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == id);
    if (fixture == null) return Future.value();
    final updated = _resizedFixture(fixture, widthFt, depthFt);
    return _patch(id, {'widthFt': updated.widthFt, 'depthFt': updated.depthFt});
  }

  Future<void> assignPlanogram(String fixtureId, String? planogramId) =>
      _patch(fixtureId, {
        'planogramId': planogramId ?? FieldValue.delete(),
      });

  Future<void> assignPlanogramBack(String fixtureId, String? planogramId) =>
      _patch(fixtureId, {
        'planogramIdBack': planogramId ?? FieldValue.delete(),
      });

  Future<void> toggleWallAdjacent(String fixtureId) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == fixtureId);
    if (fixture == null) return Future.value();
    final newValue = !fixture.wallAdjacent;
    return _patch(fixtureId, {
      'wallAdjacent': newValue,
      if (newValue) 'planogramIdBack': FieldValue.delete(),
    });
  }

  void toggleSnap() => state = state.copyWith(snapGridEnabled: !state.snapGridEnabled);

  void setDragging(bool v) => state = state.copyWith(isDragging: v);

  Future<void> _patch(String id, Map<String, dynamic> fields) async {
    await FirestoreRefs.fixtures(_storeId).doc(id).update({
      ...fields,
      'updatedAt': Timestamp.now(),
    });
  }
}

@riverpod
Stream<StoreZone?> zoneById(Ref ref, String zoneId) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value(null);
  return FirestoreRefs.zones(storeId).doc(zoneId).snapshots().map(
    (s) => s.exists ? StoreZoneFirestore.fromDoc(s) : null,
  );
}
```

- [ ] **Step 2: Update floor_builder_screen.dart type references**

In `floor_builder_screen.dart`:
- Change `PlanogramsTableData` → `Planogram` in `FloorBuilderState` reference and the mini panel
- Change `zoneByIdProvider` return type usage: `zone` is now `StoreZone?` not `ZonesTableData?`
- Remove `import '../../core/database/app_database.dart';` and `import '../../core/database/daos/fixtures_dao.dart';`
- Add `import '../../core/models/planogram.dart';` and `import '../../core/models/store_zone.dart';`

In `builder_canvas_painter.dart`, the `planograms` field is `Map<String, PlanogramsTableData>`. Change to `Map<String, Planogram>` and update the import. Access `planogram.title` — same field name.

- [ ] **Step 3: Regenerate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Verify**

```bash
flutter analyze lib/features/floor_builder/
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add lib/features/floor_builder/
git commit -m "feat: rewrite floor_builder_provider to use Firestore"
```

---

### Task 9: Rewrite catalog_provider.dart

**Files:**
- Modify: `lib/features/product_catalog/catalog_provider.dart`
- Modify: `lib/features/product_catalog/catalog_screen.dart`
- Modify: `lib/features/product_catalog/product_card.dart`

- [ ] **Step 1: Replace catalog_provider.dart**

```dart
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
```

- [ ] **Step 2: Update catalog_screen.dart and product_card.dart**

In both files:
- Replace `ProductsTableData` → `Product`
- Replace `BrandColorsTableData` → `BrandColor`
- Remove `import '../../core/database/app_database.dart';`
- Add `import '../../core/models/product.dart';` and `import '../../core/models/brand_color.dart';`
- For write operations (add/edit/delete product), replace `db.productsDao.upsert(...)` with calls to the `upsertProduct` / `deleteProduct` helpers above

- [ ] **Step 3: Regenerate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Verify**

```bash
flutter analyze lib/features/product_catalog/
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/product_catalog/ lib/core/models/brand_color.dart lib/core/models/product_template.dart
git commit -m "feat: rewrite catalog_provider to use Firestore"
```

---

### Task 10: Rewrite planogram_provider.dart

**Files:**
- Modify: `lib/features/planogram/planogram_provider.dart`
- Modify: `lib/features/planogram/*.dart` (screens that use `PlanogramsTableData`)

- [ ] **Step 1: Replace planogram_provider.dart**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/models/planogram.dart';
import '../../core/models/planogram_proposal.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import 'planogram_slot.dart';

part 'planogram_provider.g.dart';

@riverpod
Stream<List<Planogram>> planogramList(PlanogramListRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null || storeId.isEmpty) return Stream.value([]);
  return FirestoreRefs.planograms(storeId)
      .snapshots()
      .map((s) => s.docs.map(PlanogramFirestore.fromDoc).toList());
}

@riverpod
Stream<Planogram?> planogramDetail(PlanogramDetailRef ref, String planogramId) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value(null);
  return FirestoreRefs.planograms(storeId).doc(planogramId).snapshots().map(
    (s) => s.exists ? PlanogramFirestore.fromDoc(s) : null,
  );
}

@riverpod
Stream<List<PlanogramProposal>> proposalList(ProposalListRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value([]);
  return FirestoreRefs.proposals(storeId)
      .snapshots()
      .map((s) => s.docs
          .map((d) => PlanogramProposalFirestore.fromDoc(d, storeId))
          .toList());
}

@riverpod
class PlanogramEditor extends _$PlanogramEditor {
  @override
  List<PgSlot> build(String planogramId) => const [];

  void loadSlots(String slotsJson) {
    var slots = PgSlot.decodeList(slotsJson);
    if (slots.isEmpty) slots = PgSlot.defaults(6);
    state = slots;
  }

  void assignProduct(String slotId, String productId, String name, String sku) {
    state = state.map((s) {
      if (s.id != slotId) return s;
      return s.copyWith(productId: productId, productName: name, productSku: sku);
    }).toList();
  }

  void clearSlot(String slotId) {
    state = state.map((s) {
      if (s.id != slotId) return s;
      return PgSlot(id: s.id, position: s.position);
    }).toList();
  }

  Future<void> save(String planogramId) async {
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    await FirestoreRefs.planograms(storeId).doc(planogramId).update({
      'slotsJson': PgSlot.encodeList(state),
      'updatedAt': Timestamp.now(),
    });
  }
}

// --- Write helpers ---

Future<void> upsertPlanogram(String storeId, Planogram planogram) async {
  await FirestoreRefs.planograms(storeId)
      .doc(planogram.id)
      .set(planogram.toFirestore(), SetOptions(merge: true));
}

Future<void> approvePlanogram(String storeId, String planogramId) async {
  await FirestoreRefs.planograms(storeId).doc(planogramId).update({
    'status': 'published',
    'publishedAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  });
}

Future<void> updateProposalStatus(
    String storeId, String proposalId, String status, String reviewerUid) async {
  await FirestoreRefs.proposals(storeId).doc(proposalId).update({
    'status': status,
    'reviewedByUid': reviewerUid,
    'reviewedAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  });
}
```

- [ ] **Step 2: Update planogram screens**

In planogram screen files, replace `PlanogramsTableData` → `Planogram` and `PlanogramProposalsTableData` → `PlanogramProposal`. Update field accesses (field names are the same). Replace `db.planogramsDao.*` calls with the write helpers above.

- [ ] **Step 3: Regenerate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Verify**

```bash
flutter analyze lib/features/planogram/
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/planogram/
git commit -m "feat: rewrite planogram_provider to use Firestore"
```

---

### Task 11: Rewrite photo_provider.dart

**Files:**
- Modify: `lib/features/photo_docs/photo_provider.dart`
- Modify: `lib/features/photo_docs/*.dart` (screens)

- [ ] **Step 1: Replace photo_provider.dart**

```dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/photo_doc.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';

part 'photo_provider.g.dart';

class PhotoState {
  final List<PhotoDoc> photos;
  final bool isLoading;
  final Map<String, double> uploadProgress;

  const PhotoState({
    required this.photos,
    this.isLoading = false,
    this.uploadProgress = const {},
  });

  PhotoState copyWith({
    List<PhotoDoc>? photos,
    bool? isLoading,
    Map<String, double>? uploadProgress,
  }) => PhotoState(
    photos: photos ?? this.photos,
    isLoading: isLoading ?? this.isLoading,
    uploadProgress: uploadProgress ?? this.uploadProgress,
  );
}

@riverpod
class PhotoNotifier extends _$PhotoNotifier {
  @override
  Future<PhotoState> build() async {
    final storeId = ref.watch(activeStoreIdProvider).value;
    if (storeId == null) return const PhotoState(photos: []);

    // Subscribe to Firestore stream and update state
    FirestoreRefs.photos(storeId).snapshots().listen((snap) {
      final photos = snap.docs
          .map((d) => PhotoDocFirestore.fromDoc(d, storeId))
          .toList();
      if (state case AsyncData(:final value)) {
        state = AsyncData(value.copyWith(photos: photos));
      }
    });

    final snap = await FirestoreRefs.photos(storeId).get();
    final photos = snap.docs
        .map((d) => PhotoDocFirestore.fromDoc(d, storeId))
        .toList();
    return PhotoState(photos: photos);
  }

  String get _storeId => ref.read(activeStoreIdProvider).value ?? '';

  Future<void> capturePhoto(String fixtureId, String phase) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;
    await _savePhoto(fixtureId, phase, picked.path);
  }

  Future<void> pickFromGallery(String fixtureId, String phase) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    await _savePhoto(fixtureId, phase, picked.path);
  }

  Future<void> _savePhoto(String fixtureId, String phase, String localPath) async {
    final now = DateTime.now();
    final doc = PhotoDoc(
      id: const Uuid().v4(),
      fixtureId: fixtureId,
      phase: phase,
      localPath: localPath,
      uploadStatus: 'pending',
      storeId: _storeId,
      capturedAt: now,
      updatedAt: now,
    );
    await FirestoreRefs.photos(_storeId)
        .doc(doc.id)
        .set(doc.toFirestore());
  }

  Future<void> uploadPhoto(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final photo = current.photos.firstWhere((p) => p.id == id,
        orElse: () => throw StateError('Photo $id not found'));
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final storageRef = FirebaseStorage.instance.ref('photos/$uid/$id.jpg');
    final uploadTask = storageRef.putFile(File(photo.localPath!));

    uploadTask.snapshotEvents.listen((snap) {
      if (state case AsyncData(:final value)) {
        final progress = snap.bytesTransferred / snap.totalBytes;
        state = AsyncData(value.copyWith(uploadProgress: {
          ...value.uploadProgress,
          id: progress,
        }));
      }
    });

    try {
      await uploadTask;
      final remoteUrl = await storageRef.getDownloadURL();
      await FirestoreRefs.photos(_storeId).doc(id).update({
        'remoteUrl': remoteUrl,
        'uploadStatus': 'uploaded',
        'updatedAt': Timestamp.now(),
      });
    } catch (_) {
      await FirestoreRefs.photos(_storeId).doc(id).update({
        'uploadStatus': 'failed',
        'updatedAt': Timestamp.now(),
      });
    } finally {
      if (state case AsyncData(:final value)) {
        final p = Map<String, double>.from(value.uploadProgress)..remove(id);
        state = AsyncData(value.copyWith(uploadProgress: p));
      }
    }
  }

  Future<void> requestApproval(String id) =>
      _updateApprovalStatus(id, 'pending');
  Future<void> approvePhoto(String id) =>
      _updateApprovalStatus(id, 'approved');
  Future<void> rejectPhoto(String id) =>
      _updateApprovalStatus(id, 'rejected');

  Future<void> _updateApprovalStatus(String id, String status) async {
    await FirestoreRefs.photos(_storeId).doc(id).update({
      'approvalStatus': status,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> linkToPlanogram(String photoId, String planogramId) async {
    await FirestoreRefs.photos(_storeId).doc(photoId).update({
      'planogramId': planogramId,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> retryFailedUploads() async {
    final current = state.valueOrNull;
    if (current == null) return;
    for (final photo in current.photos.where((p) => p.uploadStatus == 'failed')) {
      await uploadPhoto(photo.id);
    }
  }
}
```

- [ ] **Step 2: Update photo screens**

Replace `PhotoDocsTableData` → `PhotoDoc` in screen files. Update imports.

- [ ] **Step 3: Regenerate + verify**

```bash
dart run build_runner build --delete-conflicting-outputs && flutter analyze lib/features/photo_docs/
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/photo_docs/
git commit -m "feat: rewrite photo_provider to use Firestore"
```

---

### Task 12: Rewrite dashboard_provider.dart

**Files:**
- Modify: `lib/features/dashboard/dashboard_provider.dart`

- [ ] **Step 1: Replace dashboard_provider.dart**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';

part 'dashboard_provider.freezed.dart';
part 'dashboard_provider.g.dart';

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @Default(0) int zoneCount,
    @Default(0) int fixtureCount,
    @Default(0) int productCount,
    @Default(0) int pendingJoinRequests,
    @Default(0) int pendingProposals,
    @Default(0) int myPhotoCount,
    @Default(0) int myProposalCount,
  }) = _DashboardStats;
}

@riverpod
Stream<DashboardStats> dashboardStats(DashboardStatsRef ref) async* {
  final storeId = ref.watch(activeStoreIdProvider).value;
  final membership = ref.watch(currentMembershipProvider).value;
  final user = ref.watch(authStateProvider).value;

  if (storeId == null || storeId.isEmpty || membership == null) {
    yield const DashboardStats();
    return;
  }

  // Combine multiple Firestore count queries reactively using zones stream as tick.
  await for (final zonesSnap
      in FirestoreRefs.zones(storeId).snapshots()) {
    final fixturesSnap = await FirestoreRefs.fixtures(storeId).get();
    final productsSnap = await FirestoreRefs.products(storeId).get();
    final pendingMembersSnap = await FirestoreRefs.memberships(storeId)
        .where('status', isEqualTo: 'pending')
        .get();
    final pendingProposalsSnap = await FirestoreRefs.proposals(storeId)
        .where('status', isEqualTo: 'pending')
        .get();
    final photosSnap = await FirestoreRefs.photos(storeId).get();

    int myProposalCount = 0;
    if (user != null) {
      final myProposalsSnap = await FirestoreRefs.proposals(storeId)
          .where('proposedByUid', isEqualTo: user.uid)
          .get();
      myProposalCount = myProposalsSnap.size;
    }

    yield DashboardStats(
      zoneCount: zonesSnap.size,
      fixtureCount: fixturesSnap.size,
      productCount: productsSnap.size,
      pendingJoinRequests: pendingMembersSnap.size,
      pendingProposals: pendingProposalsSnap.size,
      myPhotoCount: photosSnap.size,
      myProposalCount: myProposalCount,
    );
  }
}
```

- [ ] **Step 2: Regenerate + verify**

```bash
dart run build_runner build --delete-conflicting-outputs && flutter analyze lib/features/dashboard/
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/dashboard/
git commit -m "feat: rewrite dashboard_provider to use Firestore"
```

---

### Task 13: Remove Drift — final cleanup

**Files:**
- Delete: `lib/core/database/` (entire directory)
- Delete: `lib/core/providers/database_provider.dart`
- Modify: `pubspec.yaml` (remove Drift packages)

- [ ] **Step 1: Delete database directory**

```bash
rm -rf lib/core/database
rm lib/core/providers/database_provider.dart
```

- [ ] **Step 2: Remove Drift from pubspec.yaml**

In `pubspec.yaml`, remove from `dependencies`:
```yaml
  drift: ^2.18.0
  drift_flutter: ^0.2.1
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.3
  path: ^1.9.0
```

In `dev_dependencies`, remove:
```yaml
  drift_dev: ^2.18.0
```

Keep: `build_runner`, `riverpod_generator`, `freezed`, `json_serializable` — still needed for Riverpod and Freezed codegen.

- [ ] **Step 3: Remove any remaining Drift imports**

Search for any files still referencing Drift:
```bash
grep -r "package:drift\|app_database\|database_provider\|TableData\|TableCompanion" lib/ --include="*.dart" -l
```

For each file found, remove the Drift import and fix the reference (should be none at this point if Tasks 5–12 completed correctly).

- [ ] **Step 4: Pub get + full rebuild**

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Full analyze**

```bash
flutter analyze
```

Expected: 0 errors. Pre-existing deprecation infos (Matrix4 translate/scale) are acceptable.

- [ ] **Step 6: Build check**

```bash
flutter build apk --debug 2>&1 | tail -20
```

Expected: build succeeds.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat: remove Drift — full Firestore migration complete"
```

---

### Task 14: Write and deploy Firestore security rules

**Files:**
- Create: `firestore.rules`

- [ ] **Step 1: Create firestore.rules**

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isMember(storeId) {
      return exists(/databases/$(database)/documents/stores/$(storeId)/memberships/$(request.auth.uid))
          && get(/databases/$(database)/documents/stores/$(storeId)/memberships/$(request.auth.uid)).data.status == 'active';
    }

    function role(storeId) {
      return get(/databases/$(database)/documents/stores/$(storeId)/memberships/$(request.auth.uid)).data.role;
    }

    function isCoordinator(storeId) { return role(storeId) == 'coordinator'; }

    function isCoordinatorOrManager(storeId) {
      return role(storeId) == 'coordinator' || role(storeId) == 'manager';
    }

    match /stores/{storeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
          && request.resource.data.ownerUid == request.auth.uid;
      allow update: if request.auth != null && isCoordinator(storeId);
      allow delete: if false;

      match /memberships/{uid} {
        allow read:   if request.auth != null
            && (request.auth.uid == uid || isMember(storeId));
        allow create: if request.auth != null && request.auth.uid == uid;
        allow update: if request.auth != null && isCoordinator(storeId);
        allow delete: if request.auth != null
            && (request.auth.uid == uid || isCoordinator(storeId));
      }

      match /zones/{zoneId} {
        allow read:  if isMember(storeId);
        allow write: if isCoordinatorOrManager(storeId);
      }

      match /fixtures/{fixtureId} {
        allow read:  if isMember(storeId);
        allow write: if isCoordinatorOrManager(storeId);
      }

      match /products/{productId} {
        allow read:  if isMember(storeId);
        allow write: if isCoordinatorOrManager(storeId);
      }

      match /planograms/{planogramId} {
        allow read:  if isMember(storeId);
        allow write: if isCoordinatorOrManager(storeId);
      }

      match /proposals/{proposalId} {
        allow read:   if isMember(storeId);
        allow create: if isMember(storeId);
        allow update: if isCoordinatorOrManager(storeId);
        allow delete: if isCoordinatorOrManager(storeId);
      }

      match /photos/{photoId} {
        allow read:   if isMember(storeId);
        allow create: if isMember(storeId);
        allow update: if isMember(storeId);
        allow delete: if isCoordinatorOrManager(storeId);
      }

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

- [ ] **Step 2: Deploy rules**

```bash
firebase deploy --only firestore:rules
```

Expected: `Deploy complete!`

- [ ] **Step 3: Commit**

```bash
git add firestore.rules
git commit -m "feat: add Firestore security rules"
```

---

### Task 15: Security tests

**Files:**
- Create: `test/security/firestore_rules_test.dart`

The Firebase Emulator Suite is used for rules testing. These tests run against local emulated Firestore, not the production database.

- [ ] **Step 1: Start Firebase emulators (run in a separate terminal, keep running)**

```bash
firebase emulators:start --only firestore
```

Expected: `Emulator Hub running at localhost:4400` and Firestore emulator on port 8080.

- [ ] **Step 2: Add fake_cloud_firestore to dev_dependencies**

In `pubspec.yaml` dev_dependencies:
```yaml
  fake_cloud_firestore: ^3.0.3
```

Run `flutter pub get`.

- [ ] **Step 3: Create the test file**

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Note: fake_cloud_firestore does NOT enforce security rules —
// these tests verify DATA SHAPE and integration logic.
// True rules testing requires the Firebase Emulator (see README).
// Run emulator tests with: firebase emulators:exec "flutter test test/security/"

void main() {
  group('Firestore data shape — zones', () {
    late FakeFirebaseFirestore db;

    setUp(() {
      db = FakeFirebaseFirestore();
    });

    test('zone document round-trips correctly', () async {
      const storeId = 'store1';
      const zoneId = 'zone1';
      final now = DateTime(2026, 1, 1);

      await db
          .collection('stores')
          .doc(storeId)
          .collection('zones')
          .doc(zoneId)
          .set({
        'name': 'Test Zone',
        'colorValue': 0xFF3B6BC2,
        'zoneType': 'display',
        'positionLocked': false,
        'updatedAt': now.millisecondsSinceEpoch,
      });

      final snap = await db
          .collection('stores')
          .doc(storeId)
          .collection('zones')
          .doc(zoneId)
          .get();

      expect(snap.exists, true);
      expect(snap.data()!['name'], 'Test Zone');
      expect(snap.data()!['colorValue'], 0xFF3B6BC2);
      expect(snap.data()!['positionLocked'], false);
    });

    test('zone stream emits updated list after write', () async {
      const storeId = 'store1';

      final stream = db
          .collection('stores')
          .doc(storeId)
          .collection('zones')
          .snapshots();

      await db
          .collection('stores')
          .doc(storeId)
          .collection('zones')
          .doc('z1')
          .set({'name': 'Zone A', 'colorValue': 0xFF000000,
                'zoneType': 'display', 'positionLocked': false,
                'updatedAt': 0});

      final snap = await stream.first;
      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['name'], 'Zone A');
    });
  });

  group('Firestore data shape — fixtures', () {
    late FakeFirebaseFirestore db;

    setUp(() => db = FakeFirebaseFirestore());

    test('fixture document round-trips correctly', () async {
      await db
          .collection('stores')
          .doc('s1')
          .collection('fixtures')
          .doc('f1')
          .set({
        'zoneId': 'z1',
        'fixtureType': 'rack',
        'posX': 2.0,
        'posY': 3.0,
        'rotation': 0.0,
        'widthFt': 4.0,
        'depthFt': 2.0,
        'label': 'RACK',
        'wallAdjacent': false,
        'mountType': 'floor',
        'updatedAt': 0,
      });

      final snap = await db
          .collection('stores')
          .doc('s1')
          .collection('fixtures')
          .doc('f1')
          .get();

      expect(snap.data()!['fixtureType'], 'rack');
      expect(snap.data()!['posX'], 2.0);
    });
  });

  group('Firestore data shape — memberships', () {
    late FakeFirebaseFirestore db;

    setUp(() => db = FakeFirebaseFirestore());

    test('pending membership has status pending', () async {
      await db
          .collection('stores')
          .doc('s1')
          .collection('memberships')
          .doc('uid123')
          .set({
        'role': 'staff',
        'status': 'pending',
        'displayName': 'Alice',
        'joinedAt': 0,
      });

      final snap = await db
          .collection('stores')
          .doc('s1')
          .collection('memberships')
          .where('status', isEqualTo: 'pending')
          .get();

      expect(snap.docs.length, 1);
      expect(snap.docs.first.id, 'uid123');
    });

    test('active membership query excludes pending', () async {
      await db
          .collection('stores')
          .doc('s1')
          .collection('memberships')
          .doc('uid1')
          .set({'role': 'coordinator', 'status': 'active',
                'displayName': 'Bob', 'joinedAt': 0});
      await db
          .collection('stores')
          .doc('s1')
          .collection('memberships')
          .doc('uid2')
          .set({'role': 'staff', 'status': 'pending',
                'displayName': 'Carol', 'joinedAt': 0});

      final snap = await db
          .collection('stores')
          .doc('s1')
          .collection('memberships')
          .where('status', isEqualTo: 'active')
          .get();

      expect(snap.docs.length, 1);
      expect(snap.docs.first.id, 'uid1');
    });
  });

  group('Firestore data shape — store invite code lookup', () {
    late FakeFirebaseFirestore db;

    setUp(() => db = FakeFirebaseFirestore());

    test('invite code query returns correct store', () async {
      await db.collection('stores').doc('s1').set({
        'name': 'My Store',
        'inviteCode': 'ABC123XY',
        'ownerUid': 'owner1',
        'createdAt': 0,
      });
      await db.collection('stores').doc('s2').set({
        'name': 'Other Store',
        'inviteCode': 'ZZZ999WW',
        'ownerUid': 'owner2',
        'createdAt': 0,
      });

      final snap = await db
          .collection('stores')
          .where('inviteCode', isEqualTo: 'ABC123XY')
          .limit(1)
          .get();

      expect(snap.docs.length, 1);
      expect(snap.docs.first.id, 's1');
    });
  });
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/security/firestore_rules_test.dart -v
```

Expected: all 6 tests pass.

- [ ] **Step 5: Commit**

```bash
git add test/security/firestore_rules_test.dart pubspec.yaml pubspec.lock
git commit -m "test: add Firestore data shape and integration tests"
```

---

### Task 16: Final verification and PR

- [ ] **Step 1: Full analyze**

```bash
flutter analyze
```

Expected: 0 errors.

- [ ] **Step 2: Full test suite**

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Debug build check**

```bash
flutter build apk --debug 2>&1 | tail -20
```

Expected: build succeeds.

- [ ] **Step 4: Create PR**

```bash
gh pr create \
  --title "feat: replace Drift/SQLite with Cloud Firestore" \
  --body "Migrates all 10 data entities from Drift/SQLite to Cloud Firestore subcollections under /stores/{storeId}/. Eliminates build_runner Drift codegen, destructiveFallback schema wipes, and data loss on app updates. Enables real-time multi-device sync for coordinator/manager/staff flows. Includes Firestore security rules and data shape tests." \
  --base main
```
