// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/notifier+/computed_async_notifier.dart';
import '../../lib/notifier+/watch_async_computed.dart';

void main() {
  group('WatchAsyncComputed', () {
    testWidgets('displays initial computed value and updates on dependency change',
        (WidgetTester tester) async {
      // Create a dummy dependency notifier.
      final dependency = ChangeNotifier();
      int computeCallCount = 0;
      
      // Compute function that returns incremented values.
      Future<int> compute() async {
        computeCallCount++;
        return computeCallCount;
      }
      
      // Create a ComputedAsyncNotifier with the dependency.
      final computedNotifier = ComputedAsyncNotifier<int>(
        compute,
        depends: [dependency],
      );
      
      // Build the WatchAsyncComputed widget.
      await tester.pumpWidget(
        MaterialApp(
          home: WatchAsyncComputed<int>(
            computed: computedNotifier,
            builder: (context, value) {
              return Text(
                value?.toString() ?? 'null',
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      );
      
      // Allow the initial microtasks to complete.
      await tester.pumpAndSettle();
      
      // The initial computed value should be 1.
      expect(find.text('1'), findsOneWidget);
      
      // Simulate a dependency change.
      dependency.notifyListeners();
      
      // Wait for the microtask scheduled by oneCallTask.
      await tester.pumpAndSettle();
      
      // The computed value should now update to 2.
      expect(find.text('2'), findsOneWidget);
      
      // Simulate another dependency change.
      dependency.notifyListeners();
      await tester.pumpAndSettle();
      
      // The computed value should now update to 3.
      expect(find.text('3'), findsOneWidget);
    });
  });
}
