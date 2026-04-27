import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:merch_mobile/core/models/fixture.dart';
import 'package:merch_mobile/features/floor_builder/fixture_mini_panel.dart';

GoRouter _makeRouter() => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: SizedBox.shrink()),
          routes: [
            GoRoute(
              path: 'planograms/:planogramId',
              name: 'planogramDetail',
              builder: (_, __) => const Scaffold(body: SizedBox.shrink()),
            ),
          ],
        ),
      ],
    );

void main() {
  final baseFixture = Fixture(
    id: 'f1',
    zoneId: 'z1',
    fixtureType: 'rack',
    widthFt: 4.0,
    depthFt: 2.0,
    label: 'WOMEN RACK',
    updatedAt: DateTime(2025),
  );

  Widget buildPanel({
    required Fixture fixture,
    VoidCallback? onDismiss,
  }) {
    return MaterialApp.router(
      routerConfig: _makeRouter(),
      builder: (context, child) => Scaffold(
        body: FixtureMiniPanel(
          fixture: fixture,
          planogram: null,
          onDismiss: onDismiss ?? () {},
        ),
      ),
    );
  }

  testWidgets('shows fixture label and dimensions', (tester) async {
    await tester.pumpWidget(buildPanel(fixture: baseFixture));
    expect(find.text('WOMEN RACK'), findsOneWidget);
    expect(find.text('4.0 \u00d7 2.0 ft'), findsOneWidget);
  });

  testWidgets('shows No planogram when unassigned', (tester) async {
    await tester.pumpWidget(buildPanel(fixture: baseFixture));
    expect(find.text('No planogram'), findsOneWidget);
    expect(find.text('VIEW \u2192'), findsNothing);
  });

  testWidgets('shows fixture type when label is empty', (tester) async {
    final noLabel = baseFixture.copyWith(label: '');
    await tester.pumpWidget(buildPanel(fixture: noLabel));
    expect(find.text('RACK'), findsOneWidget);
  });

  testWidgets('calls onDismiss when X tapped', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
        buildPanel(fixture: baseFixture, onDismiss: () => dismissed = true));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(dismissed, isTrue);
  });
}
