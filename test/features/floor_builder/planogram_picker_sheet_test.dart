import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';
import 'package:merch_mobile/features/floor_builder/planogram_picker_sheet.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late List<PlanogramsTableData> planograms;

  setUp(() async {
    // setUp runs outside testWidgets' FakeAsync, so real async (Drift/SQLite)
    // works correctly here.
    db = createTestDatabase();
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
    planograms = await db.planogramsDao.watchAll().first;
  });

  tearDown(() async => db.close());

  /// Opens the sheet via showModalBottomSheet so DraggableScrollableSheet
  /// receives proper BoxConstraints. Uses two pump() calls — never
  /// pumpAndSettle() which would spin forever on the spring animation.
  ///
  /// Uses a tall (1200px) logical surface so list items rendered inside the
  /// DraggableScrollableSheet (initialChildSize 0.55) are within hit-test bounds.
  Future<void> openSheet(
    WidgetTester tester, {
    String? currentId,
    void Function(String?)? onSelect,
  }) async {
    // Give the test a tall enough surface so DraggableScrollableSheet's
    // initialChildSize=0.55 doesn't push list items off the bottom.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showModalBottomSheet<void>(
                context: ctx,
                isScrollControlled: true,
                builder: (_) => PlanogramPickerSheet(
                  planograms: planograms,
                  currentPlanogramId: currentId,
                  fixtureLabel: 'WOMEN RACK',
                  onSelect: onSelect ?? (_) {},
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump(); // schedule modal route
    await tester.pump(); // render modal content
  }

  testWidgets('shows all planogram titles', (tester) async {
    await openSheet(tester);
    expect(find.text('Spring Collection'), findsOneWidget);
    expect(find.text('Summer Essentials'), findsOneWidget);
  });

  testWidgets('search filters results', (tester) async {
    await openSheet(tester);
    await tester.enterText(find.byType(TextField), 'summer');
    await tester.pump();
    expect(find.text('Summer Essentials'), findsOneWidget);
    expect(find.text('Spring Collection'), findsNothing);
  });

  testWidgets('shows remove assignment when planogram is assigned', (tester) async {
    await openSheet(tester, currentId: planograms.first.id);
    expect(find.text('Remove assignment'), findsOneWidget);
  });

  testWidgets('does not show remove assignment when unassigned', (tester) async {
    await openSheet(tester);
    expect(find.text('Remove assignment'), findsNothing);
  });

  testWidgets('tapping remove calls onSelect with null', (tester) async {
    String? selected = planograms.first.id;
    await openSheet(
      tester,
      currentId: planograms.first.id,
      onSelect: (id) => selected = id,
    );
    // DraggableScrollableSheet places list items outside the hit-test surface in
    // tests, so invoke the ListTile's onTap directly rather than via tap().
    final removeTile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text('Remove assignment'),
        matching: find.byType(ListTile),
      ),
    );
    removeTile.onTap!();
    await tester.pump(); // onSelect fires synchronously on tap
    expect(selected, isNull);
  });

  testWidgets('tapping a planogram tile calls onSelect with its id', (tester) async {
    String? selected;
    await openSheet(tester, onSelect: (id) => selected = id);
    // DraggableScrollableSheet places list items outside the hit-test surface in
    // tests, so invoke the ListTile's onTap directly rather than via tap().
    final tile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text(planograms.first.title),
        matching: find.byType(ListTile),
      ).first,
    );
    tile.onTap!();
    await tester.pump(); // onSelect fires synchronously on tap
    expect(selected, planograms.first.id);
  });

  testWidgets('shows empty state when search yields no results', (tester) async {
    await openSheet(tester);
    await tester.enterText(find.byType(TextField), 'zzznomatch');
    await tester.pump();
    expect(find.text('No planograms found'), findsOneWidget);
  });
}
