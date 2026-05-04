import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/widgets/mm_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('MmButton — filled (default)', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton(label: 'Save', onPressed: () {}),
      ));
      await tester.pump();
      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('uses ElevatedButton', (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton(label: 'Save', onPressed: () {}),
      ));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('onPressed fires when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        MmButton(label: 'Save', onPressed: () => tapped = true),
      ));
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton).first);
      expect(tapped, isTrue);
    });

    testWidgets('onPressed: null disables the button', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmButton(label: 'Save', onPressed: null),
      ));
      await tester.pump();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });
  });

  group('MmButton.outlined', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton.outlined(label: 'Cancel', onPressed: () {}),
      ));
      await tester.pump();
      expect(find.text('CANCEL'), findsOneWidget);
    });

    testWidgets('uses OutlinedButton', (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton.outlined(label: 'Cancel', onPressed: () {}),
      ));
      await tester.pump();
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('MmButton.destructive', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton.destructive(label: 'Delete', onPressed: () {}),
      ));
      await tester.pump();
      expect(find.text('DELETE'), findsOneWidget);
    });

    testWidgets('uses ElevatedButton', (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton.destructive(label: 'Delete', onPressed: () {}),
      ));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });

  group('MmButton.text', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton.text(label: 'Skip', onPressed: () {}),
      ));
      await tester.pump();
      expect(find.text('SKIP'), findsOneWidget);
    });

    testWidgets('uses TextButton', (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton.text(label: 'Skip', onPressed: () {}),
      ));
      await tester.pump();
      expect(find.byType(TextButton), findsOneWidget);
    });
  });

  group('MmButton — isLoading', () {
    testWidgets('shows CircularProgressIndicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton(label: 'Save', onPressed: () {}, isLoading: true),
      ));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides label text when isLoading is true', (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton(label: 'Save', onPressed: () {}, isLoading: true),
      ));
      await tester.pump();
      expect(find.text('SAVE'), findsNothing);
    });

    testWidgets('disables tap when isLoading is true', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        MmButton(label: 'Save', onPressed: () => tapped = true, isLoading: true),
      ));
      await tester.pump();
      // The ElevatedButton onPressed should be null (disabled)
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
      expect(tapped, isFalse);
    });

    testWidgets('outlined isLoading disables OutlinedButton', (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton.outlined(label: 'Go', onPressed: () {}, isLoading: true),
      ));
      await tester.pump();
      final btn = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('text isLoading disables TextButton', (tester) async {
      await tester.pumpWidget(_wrap(
        MmButton.text(label: 'Skip', onPressed: () {}, isLoading: true),
      ));
      await tester.pump();
      final btn = tester.widget<TextButton>(find.byType(TextButton));
      expect(btn.onPressed, isNull);
    });
  });
}
