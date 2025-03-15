// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/notifier+/computed_notifier.dart';

void main() {
  group('ComputedNotifier', () {
    test('initial computation', () {
      int computeCallCount = 0;
      int computedValue = 0;

      // Compute function returns an incremented value.
      int compute() {
        computeCallCount++;
        return ++computedValue;
      }

      final dependency = ChangeNotifier();
      final notifier = ComputedNotifier<int>(compute, depends: [dependency]);

      // The first access triggers the computation.
      expect(notifier.value, equals(1));
      expect(computeCallCount, equals(1));
    });

    test('re-computation on dependency change', () async {
      int computeCallCount = 0;
      int computedValue = 10;

      // Compute function returns current value and increments it.
      int compute() {
        computeCallCount++;
        return computedValue++;
      }

      final dependency = ChangeNotifier();
      final notifier = ComputedNotifier<int>(compute, depends: [dependency]);

      // First access computes the initial value.
      expect(notifier.value, equals(10));
      expect(computeCallCount, equals(1));

      // Trigger dependency change.
      dependency.notifyListeners();

      // Wait for microtasks to complete as oneCallTask schedules a microtask.
      await Future.delayed(Duration.zero);

      // The re-computation should occur.
      expect(notifier.value, equals(11));
      expect(computeCallCount, equals(2));
    });

    test('forceValue updates value and notifies listeners', () async {
      // ignore: unused_local_variable
      int computeCallCount = 0;
      int computedValue = 5;

      // Compute function returns a fixed value.
      int compute() {
        computeCallCount++;
        return computedValue;
      }

      final dependency = ChangeNotifier();
      final notifier = ComputedNotifier<int>(compute, depends: [dependency]);

      // Listen to notifications.
      int notificationCount = 0;
      notifier.addListener(() {
        notificationCount++;
      });

      // Trigger initial computation.
      expect(notifier.value, equals(5));
      expect(notificationCount, equals(0));

      // Force a new value.
      notifier.forceValue(100);
      expect(notifier.value, equals(100));
      expect(notificationCount, equals(1));
    });
  });
}
