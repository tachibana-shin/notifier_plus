import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifier_plus/composables/watch.dart';

void main() {
  group('watch function', () {
    test('calls callback immediately when immediate is true', () async {
      int callCount = 0;
      void callback() {
        callCount++;
      }

      // Create a ValueNotifier to act as dependency.
      final notifier = ValueNotifier<int>(0);

      // Call watch with immediate true.
      final unregister = watch([notifier], callback, immediate: true);

      // Wait for microtasks to complete.
      await Future.delayed(Duration.zero);

      // The callback should have been called immediately.
      expect(callCount, equals(1));

      // Cleanup.
      unregister();
    });

    test('calls callback on dependency change (once per microtask)', () async {
      int callCount = 0;
      void callback() {
        callCount++;
      }

      final notifier = ValueNotifier<int>(0);
      final unregister = watch([notifier], callback);

      // Update the notifier value.
      notifier.value = 1;

      // Wait for microtasks to complete.
      await Future.delayed(Duration.zero);

      expect(callCount, equals(1));

      // Trigger multiple changes in the same microtask.
      notifier.value = 2;
      notifier.value = 3;

      await Future.delayed(Duration.zero);

      // Even though notifier changed twice within the same microtask,
      // the callback should be executed only once due to oneCallTask.
      expect(callCount, equals(2));

      // Cleanup.
      unregister();
    });

    test('unregister callback stops further callback invocations', () async {
      int callCount = 0;
      void callback() {
        callCount++;
      }

      final notifier = ValueNotifier<int>(0);
      final unregister = watch([notifier], callback);

      // Unregister the callback.
      unregister();

      // Change the notifier value.
      notifier.value = 10;
      await Future.delayed(Duration.zero);

      // Since the callback is unregistered, callCount remains 0.
      expect(callCount, equals(0));
    });
  });
}
