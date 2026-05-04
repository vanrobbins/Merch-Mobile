import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/widgets/mm_eyebrow.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('MmEyebrow', () {
    testWidgets('renders text converted to upper case', (tester) async {
      await tester.pumpWidget(_wrap(const MmEyebrow('section label')));
      await tester.pump();
      expect(find.text('SECTION LABEL'), findsOneWidget);
    });

    testWidgets('already-uppercase text renders correctly', (tester) async {
      await tester.pumpWidget(_wrap(const MmEyebrow('TOPS')));
      await tester.pump();
      expect(find.text('TOPS'), findsOneWidget);
    });

    testWidgets('text has fontSize 10', (tester) async {
      await tester.pumpWidget(_wrap(const MmEyebrow('label')));
      await tester.pump();
      final textWidget = tester.widget<Text>(find.text('LABEL'));
      expect(textWidget.style?.fontSize, 10.0);
    });

    testWidgets('text has letterSpacing 1.2', (tester) async {
      await tester.pumpWidget(_wrap(const MmEyebrow('label')));
      await tester.pump();
      final textWidget = tester.widget<Text>(find.text('LABEL'));
      expect(textWidget.style?.letterSpacing, 1.2);
    });

    testWidgets('text has fontWeight w700', (tester) async {
      await tester.pumpWidget(_wrap(const MmEyebrow('label')));
      await tester.pump();
      final textWidget = tester.widget<Text>(find.text('LABEL'));
      expect(textWidget.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('applies custom padding when provided', (tester) async {
      const customPadding = EdgeInsets.all(20);
      await tester.pumpWidget(_wrap(
        const MmEyebrow('label', padding: customPadding),
      ));
      await tester.pump();
      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, customPadding);
    });

    testWidgets('uses default bottom-only padding when not provided',
        (tester) async {
      await tester.pumpWidget(_wrap(const MmEyebrow('label')));
      await tester.pump();
      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.only(bottom: 8));
    });
  });
}
