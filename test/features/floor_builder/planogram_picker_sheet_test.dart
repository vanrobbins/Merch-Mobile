import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';
import 'package:merch_mobile/features/floor_builder/planogram_picker_sheet.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() async => await db.close());

  Future<List<PlanogramsTableData>> seedPlanograms() async {
    await db.planogramsDao.upsert(PlanogramsTableCompanion.insert(
      id: 'p1',
      fixtureId: 'fixture_a',
      title: 'Spring Collection',
      season: 'Spring 2025',
      updatedAt: DateTime(2025, 1, 1),
    ));
    await db.planogramsDao.upsert(PlanogramsTableCompanion.insert(
      id: 'p2',
      fixtureId: 'fixture_b',
      title: 'Summer Essentials',
      season: 'Summer 2025',
      updatedAt: DateTime(2025, 6, 1),
    ));
    return db.planogramsDao.watchAll().first;
  }

  Widget buildSheet({
    required List<PlanogramsTableData> planograms,
    String? currentId,
    void Function(String?)? onSelect,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PlanogramPickerSheet(
          planograms: planograms,
          currentPlanogramId: currentId,
          fixtureLabel: 'WOMEN RACK',
          onSelect: onSelect ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('shows all planogram titles', (tester) async {
    final planograms = await seedPlanograms();
    await tester.pumpWidget(buildSheet(planograms: planograms));
    await tester.pump();
    expect(find.text('Spring Collection'), findsOneWidget);
    expect(find.text('Summer Essentials'), findsOneWidget);
  });

  testWidgets('search filters results', (tester) async {
    final planograms = await seedPlanograms();
    await tester.pumpWidget(buildSheet(planograms: planograms));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'summer');
    await tester.pump();
    expect(find.text('Summer Essentials'), findsOneWidget);
    expect(find.text('Spring Collection'), findsNothing);
  });

  testWidgets('shows remove assignment when planogram is assigned', (tester) async {
    final planograms = await seedPlanograms();
    await tester.pumpWidget(
        buildSheet(planograms: planograms, currentId: planograms.first.id));
    await tester.pump();
    expect(find.text('Remove assignment'), findsOneWidget);
  });

  testWidgets('does not show remove assignment when unassigned', (tester) async {
    final planograms = await seedPlanograms();
    await tester.pumpWidget(buildSheet(planograms: planograms));
    await tester.pump();
    expect(find.text('Remove assignment'), findsNothing);
  });

  testWidgets('tapping remove calls onSelect with null', (tester) async {
    final planograms = await seedPlanograms();
    String? selected = planograms.first.id;
    await tester.pumpWidget(buildSheet(
      planograms: planograms,
      currentId: planograms.first.id,
      onSelect: (id) => selected = id,
    ));
    await tester.pump();
    await tester.tap(find.text('Remove assignment'));
    await tester.pumpAndSettle();
    expect(selected, isNull);
  });

  testWidgets('tapping a planogram tile calls onSelect with its id', (tester) async {
    final planograms = await seedPlanograms();
    String? selected;
    await tester.pumpWidget(
        buildSheet(planograms: planograms, onSelect: (id) => selected = id));
    await tester.pump();
    await tester.tap(find.text(planograms.first.title));
    await tester.pumpAndSettle();
    expect(selected, planograms.first.id);
  });

  testWidgets('shows empty state when search yields no results', (tester) async {
    final planograms = await seedPlanograms();
    await tester.pumpWidget(buildSheet(planograms: planograms));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'zzznomatch');
    await tester.pump();
    expect(find.text('No planograms found'), findsOneWidget);
  });
}
