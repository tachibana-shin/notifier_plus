// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/notifier+/computed_notifier.dart';
import '../../lib/notifier+/watch_computed.dart';

void main() {
  group('WatchComputed', () {
    testWidgets('displays initial computed value and updates on dependency change', (WidgetTester tester) async {
      int computeCallCount = 0;
      int computedValue = 5;
      
      // Compute function returns a value and increments call count.
      int compute() {
        computeCallCount++;
        return computedValue;
      }
      
      // Create a dependency notifier.
      final dependency = ChangeNotifier();
      
      // Create the ComputedNotifier with the dependency.
      final computedNotifier = ComputedNotifier<int>(compute, depends: [dependency]);
      
      // Build the WatchComputed widget.
      await tester.pumpWidget(
        MaterialApp(
          home: WatchComputed<int>(
            computed: computedNotifier,
            builder: (context, value) => Text(
              value.toString(),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );
      
      // The initial value is computed during the first build.
      expect(find.text('5'), findsOneWidget);
      expect(computeCallCount, equals(1));
      
      // Change the underlying computed value.
      computedValue = 10;
      
      // Trigger a dependency change.
      dependency.notifyListeners();
      
      // Wait for microtasks scheduled by oneCallTask to complete.
      await tester.pumpAndSettle();
      
      // The widget should rebuild with the new computed value.
      expect(find.text('10'), findsOneWidget);
      expect(computeCallCount, equals(2));
    });
  });
}
