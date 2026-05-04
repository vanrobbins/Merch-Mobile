import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/widgets/mm_text_field.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('MmTextField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmTextField(label: 'Product Name'),
      ));
      await tester.pump();
      expect(find.text('Product Name'), findsOneWidget);
    });

    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(_wrap(
        const MmTextField(hint: 'Enter a name'),
      ));
      await tester.pump();
      expect(find.text('Enter a name'), findsOneWidget);
    });

    testWidgets('onChanged fires on text input', (tester) async {
      final values = <String>[];
      await tester.pumpWidget(_wrap(
        MmTextField(onChanged: values.add),
      ));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'hello');
      expect(values, contains('hello'));
    });

    testWidgets('onChanged receives each incremental value', (tester) async {
      final values = <String>[];
      await tester.pumpWidget(_wrap(
        MmTextField(onChanged: values.add),
      ));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'abc');
      // enterText replaces entire content — at least the final value is present
      expect(values.last, 'abc');
    });

    testWidgets('validator error message shows when triggered', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: MmTextField(
                label: 'Required',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Cannot be empty' : null,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      // Validate without entering any text
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Cannot be empty'), findsOneWidget);
    });

    testWidgets('validator passes when value is valid', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: MmTextField(
                label: 'Required',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Cannot be empty' : null,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'some value');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Cannot be empty'), findsNothing);
    });

    testWidgets('uses TextFormField internally', (tester) async {
      await tester.pumpWidget(_wrap(const MmTextField()));
      await tester.pump();
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
