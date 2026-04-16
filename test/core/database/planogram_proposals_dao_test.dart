import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() async => await db.close());

  PlanogramProposalsTableCompanion proposal(
    String id, {
    String status = 'pending',
    String storeId = 'store1',
    String planogramId = 'plano1',
    String proposedByUid = 'user1',
    int proposedAt = 1000,
  }) =>
      PlanogramProposalsTableCompanion.insert(
        id: id,
        planogramId: planogramId,
        storeId: storeId,
        proposedByUid: proposedByUid,
        proposedAt: proposedAt,
        status: status,
      );

  group('PlanogramProposalsDao', () {
    test('watchPendingByStore returns only pending proposals', () async {
      await db.planogramProposalsDao.upsert(proposal('pr1'));
      await db.planogramProposalsDao
          .upsert(proposal('pr2', status: 'approved'));
      final pending =
          await db.planogramProposalsDao.watchPendingByStore('store1').first;
      expect(pending.length, 1);
      expect(pending.first.id, 'pr1');
    });

    test('upsert updates proposal status', () async {
      await db.planogramProposalsDao.upsert(proposal('pr3'));
      await db.planogramProposalsDao
          .upsert(proposal('pr3', status: 'rejected'));
      final pending =
          await db.planogramProposalsDao.watchPendingByStore('store1').first;
      expect(pending.any((p) => p.id == 'pr3'), isFalse);
    });

    test('watchByStore returns all proposals ordered by proposedAt desc',
        () async {
      await db.planogramProposalsDao
          .upsert(proposal('pr4', proposedAt: 1000));
      await db.planogramProposalsDao
          .upsert(proposal('pr5', proposedAt: 3000));
      await db.planogramProposalsDao
          .upsert(proposal('pr6', proposedAt: 2000));

      final all =
          await db.planogramProposalsDao.watchByStore('store1').first;
      expect(all.map((p) => p.id).toList(), ['pr5', 'pr6', 'pr4']);
    });

    test('watchByUser filters by uid within a store', () async {
      await db.planogramProposalsDao
          .upsert(proposal('pr7', proposedByUid: 'alice'));
      await db.planogramProposalsDao
          .upsert(proposal('pr8', proposedByUid: 'bob'));
      await db.planogramProposalsDao.upsert(
          proposal('pr9', proposedByUid: 'alice', storeId: 'store2'));

      final alice =
          await db.planogramProposalsDao.watchByUser('store1', 'alice').first;
      expect(alice.map((p) => p.id), contains('pr7'));
      expect(alice.map((p) => p.id), isNot(contains('pr8')));
      expect(alice.map((p) => p.id), isNot(contains('pr9')));
    });

    test('deleteById removes proposal', () async {
      await db.planogramProposalsDao.upsert(proposal('pr10'));
      await db.planogramProposalsDao.deleteById('pr10');
      final pending =
          await db.planogramProposalsDao.watchPendingByStore('store1').first;
      expect(pending.any((p) => p.id == 'pr10'), isFalse);
    });

    test('watchPendingByStore does not leak cross-store proposals', () async {
      await db.planogramProposalsDao
          .upsert(proposal('pr11', storeId: 'storeX'));
      await db.planogramProposalsDao
          .upsert(proposal('pr12', storeId: 'storeY'));

      final x =
          await db.planogramProposalsDao.watchPendingByStore('storeX').first;
      expect(x.length, 1);
      expect(x.first.id, 'pr11');
    });
  });
}
