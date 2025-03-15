// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/notifier+/computed_notifier.dart';
import '../../lib/notifier+/watch_computes.dart';

void main() {
  group('WatchComputes', () {
    testWidgets('updates when one of the computed notifiers changes', (WidgetTester tester) async {
      // External mutable values for our computed functions.
      int value1 = 1;
      int value2 = 10;

      // Create dependencies for each computed notifier.
      final dependency1 = ChangeNotifier();
      final dependency2 = ChangeNotifier();

      // ComputedNotifier that reads the external value1.
      final computedNotifier1 = ComputedNotifier<int>(
        () => value1,
        depends: [dependency1],
      );

      // ComputedNotifier that reads the external value2.
      final computedNotifier2 = ComputedNotifier<int>(
        () => value2,
        depends: [dependency2],
      );

      // The builder reads the current values from both computed notifiers.
      Widget testWidget = MaterialApp(
        home: WatchComputes<int>(
          computes: [computedNotifier1, computedNotifier2],
          builder: (context) {
            // Combine the values for display.
            final text = '${computedNotifier1.value} & ${computedNotifier2.value}';
            return Text(
              text,
              textDirection: TextDirection.ltr,
            );
          },
        ),
      );

      // Pump the widget.
      await tester.pumpWidget(testWidget);
      // Initial build: computed values should be 1 and 10.
      expect(find.text('1 & 10'), findsOneWidget);

      // Change the external value1 and notify its dependency.
      value1 = 5;
      dependency1.notifyListeners();

      // Allow the oneCallTask microtask to complete.
      await tester.pumpAndSettle();

      // The updated build should now show updated value for computedNotifier1.
      expect(find.text('5 & 10'), findsOneWidget);

      // Now, change the external value2 and notify its dependency.
      value2 = 20;
      dependency2.notifyListeners();

      // Wait for the update.
      await tester.pumpAndSettle();

      // The updated build should reflect both new values.
      expect(find.text('5 & 20'), findsOneWidget);
    });
  });
}
