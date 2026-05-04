import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/widgets/mm_list_tile.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('MmListTile', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmListTile(title: 'My Item'),
      ));
      await tester.pump();
      expect(find.text('My Item'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmListTile(title: 'My Item', subtitle: 'Sub text'),
      ));
      await tester.pump();
      expect(find.text('Sub text'), findsOneWidget);
    });

    testWidgets('does not render subtitle when omitted', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmListTile(title: 'My Item'),
      ));
      await tester.pump();
      // Only title text, no extra text widget
      expect(find.text('Sub text'), findsNothing);
    });

    testWidgets('renders leading widget when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmListTile(
          title: 'My Item',
          leading: Icon(Icons.star, key: Key('leading-icon')),
        ),
      ));
      await tester.pump();
      expect(find.byKey(const Key('leading-icon')), findsOneWidget);
    });

    testWidgets('renders trailing chevron_right icon when onTap provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        MmListTile(title: 'Tappable', onTap: () {}),
      ));
      await tester.pump();
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('does NOT render trailing chevron when onTap is null',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const MmListTile(title: 'Static item'),
      ));
      await tester.pump();
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        MmListTile(title: 'Tap me', onTap: () => tapped = true),
      ));
      await tester.pump();
      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('trailing widget overrides default chevron', (tester) async {
      await tester.pumpWidget(_wrap(
        MmListTile(
          title: 'Custom trailing',
          onTap: () {},
          trailing: const Icon(Icons.arrow_forward, key: Key('custom-trail')),
        ),
      ));
      await tester.pump();
      // Custom trailing shown, default chevron_right not shown
      expect(find.byKey(const Key('custom-trail')), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });

  group('MmListSection', () {
    testWidgets('renders all children', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmListSection(
          children: [
            MmListTile(title: 'Item A'),
            MmListTile(title: 'Item B'),
            MmListTile(title: 'Item C'),
          ],
        ),
      ));
      await tester.pump();
      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
      expect(find.text('Item C'), findsOneWidget);
    });

    testWidgets('renders dividers between children', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmListSection(
          children: [
            MmListTile(title: 'Item A'),
            MmListTile(title: 'Item B'),
            MmListTile(title: 'Item C'),
          ],
        ),
      ));
      await tester.pump();
      // 3 children → 2 dividers between them
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('no divider when only one child', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmListSection(
          children: [
            MmListTile(title: 'Solo'),
          ],
        ),
      ));
      await tester.pump();
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('renders header eyebrow when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmListSection(
          header: 'Section Title',
          children: [
            MmListTile(title: 'Item'),
          ],
        ),
      ));
      await tester.pump();
      // MmEyebrow converts to upper case
      expect(find.text('SECTION TITLE'), findsOneWidget);
    });

    testWidgets('no header rendered when omitted', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmListSection(
          children: [
            MmListTile(title: 'Item'),
          ],
        ),
      ));
      await tester.pump();
      expect(find.text('SECTION TITLE'), findsNothing);
    });
  });
}
