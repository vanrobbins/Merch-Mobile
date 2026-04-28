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
        'updatedAt': 0,
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
          .set({
            'name': 'Zone A',
            'colorValue': 0xFF000000,
            'zoneType': 'display',
            'positionLocked': false,
            'updatedAt': 0,
          });

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
          .set({
            'role': 'coordinator',
            'status': 'active',
            'displayName': 'Bob',
            'joinedAt': 0,
          });
      await db
          .collection('stores')
          .doc('s1')
          .collection('memberships')
          .doc('uid2')
          .set({
            'role': 'staff',
            'status': 'pending',
            'displayName': 'Carol',
            'joinedAt': 0,
          });

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
