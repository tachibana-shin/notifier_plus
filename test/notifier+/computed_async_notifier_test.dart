// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notifier_plus/notifier+/computed_async_notifier.dart';

void main() {
  group('ComputedAsyncNotifier', () {
    test('computes initial value correctly', () async {
      // Create a dummy dependency.
      final dependency = ChangeNotifier();

      // Compute function that returns 42.
      Future<int> compute() async => 42;

      final notifier = ComputedAsyncNotifier<int>(
        compute,
        depends: [dependency],
      );

      // Initially, the getter triggers computation; value is not yet computed.
      expect(notifier.value, isNull);

      // Wait for the scheduled microtask to complete.
      await Future.delayed(Duration.zero);

      // Now, the value should have been computed.
      expect(notifier.value, equals(42));
      expect(notifier.loading, isFalse);
      expect(notifier.error, isNull);

      notifier.dispose();
    });

    test('triggers re-computation on dependency change', () async {
      final dependency = ChangeNotifier();
      int computeCallCount = 0;
      Future<int> compute() async {
        computeCallCount++;
        return computeCallCount;
      }

      final notifier = ComputedAsyncNotifier<int>(
        compute,
        depends: [dependency],
      );

      // Trigger the initial computation.
      expect(notifier.value, isNull);
      await Future.delayed(Duration.zero);
      expect(notifier.value, equals(1));

      // Simulate a change in the dependency.
      dependency.notifyListeners();
      // Wait for the microtask that schedules the update.
      await Future.delayed(Duration.zero);
      // The computation should run again.
      expect(notifier.value, equals(2));

      notifier.dispose();
    });

    test('calls onBeforeUpdate and handles error in compute', () async {
      final dependency = ChangeNotifier();
      bool onBeforeUpdateCalled = false;
      bool onErrorCalled = false;

      // Compute function that always throws.
      Future<int> compute() async {
        await Future.delayed(Duration(milliseconds: 199));
        throw Exception();
      }

      int? onBeforeUpdate() {
        onBeforeUpdateCalled = true;
        // Return a temporary value before re-computation.
        return 100;
      }

      void onError(dynamic error) {
        onErrorCalled = true;
      }

      final notifier = ComputedAsyncNotifier<int>(
        compute,
        depends: [dependency],
        beforeUpdate: onBeforeUpdate,
        onError: onError,
      );

      /// Trigger the initial computation.
      notifier.value;

      await Future.delayed(Duration.zero);
      // Since compute throws, the value remains unchanged.
      expect(notifier.value, equals(100));
      await Future.delayed(Duration.zero);
      // Since compute throws, the value remains unchanged.
      expect(notifier.value, equals(100));
      await Future.delayed(Duration(milliseconds: 300));
      // Error should be stored.
      expect(notifier.error, isNotNull);
      expect(onBeforeUpdateCalled, isTrue);
      expect(onErrorCalled, isTrue);

      notifier.dispose();
    });
  });
}
