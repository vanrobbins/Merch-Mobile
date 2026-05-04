import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/widgets/mm_dialog.dart';

/// Pumps a minimal app with a button that triggers [MmDialog.show].
Widget _appWithTrigger({
  required String title,
  required Widget content,
  List<Widget> actions = const [],
}) =>
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => MmDialog.show(
              ctx,
              title: title,
              content: content,
              actions: actions,
            ),
            child: const Text('OPEN'),
          ),
        ),
      ),
    );

void main() {
  group('MmDialog.show', () {
    testWidgets('renders title text (converted to upper case)', (tester) async {
      await tester.pumpWidget(_appWithTrigger(
        title: 'confirm',
        content: const Text('Are you sure?'),
      ));
      await tester.pump();
      await tester.tap(find.text('OPEN'));
      await tester.pump(); // trigger dialog open
      // title.toUpperCase() is applied inside MmDialog
      expect(find.text('CONFIRM'), findsOneWidget);
    });

    testWidgets('renders content widget', (tester) async {
      await tester.pumpWidget(_appWithTrigger(
        title: 'Info',
        content: const Text('Dialog body text'),
      ));
      await tester.pump();
      await tester.tap(find.text('OPEN'));
      await tester.pump();
      expect(find.text('Dialog body text'), findsOneWidget);
    });

    testWidgets('renders provided action widgets', (tester) async {
      await tester.pumpWidget(_appWithTrigger(
        title: 'Alert',
        content: const Text('Body'),
        actions: [
          const TextButton(onPressed: null, child: Text('DISMISS')),
        ],
      ));
      await tester.pump();
      await tester.tap(find.text('OPEN'));
      await tester.pump();
      expect(find.text('DISMISS'), findsOneWidget);
    });

    testWidgets('renders multiple action buttons', (tester) async {
      await tester.pumpWidget(_appWithTrigger(
        title: 'Alert',
        content: const Text('Body'),
        actions: [
          const TextButton(onPressed: null, child: Text('CANCEL')),
          const TextButton(onPressed: null, child: Text('OK')),
        ],
      ));
      await tester.pump();
      await tester.tap(find.text('OPEN'));
      await tester.pump();
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('wraps content in an AlertDialog', (tester) async {
      await tester.pumpWidget(_appWithTrigger(
        title: 'Test',
        content: const Text('Content'),
      ));
      await tester.pump();
      await tester.tap(find.text('OPEN'));
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
