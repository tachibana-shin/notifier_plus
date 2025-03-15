import 'package:flutter_test/flutter_test.dart';

import '../../lib/notifier+/notifier.dart';

void main() {
  group('Notifier', () {
    test('initial value is set correctly', () {
      final notifier = Notifier<int>(10);
      expect(notifier.value, equals(10));
    });

    test('updates value and notifies listeners when value changes', () async {
      final notifier = Notifier<int>(10);
      int notificationCount = 0;

      // Add a listener that increments the notification count.
      notifier.addListener(() {
        notificationCount++;
      });

      // Set a new value that is different.
      notifier.value = 20;

      // Wait for microtasks to complete (oneCallTask schedules a microtask).
      await Future.delayed(Duration.zero);

      expect(notifier.value, equals(20));
      expect(notificationCount, equals(1));
    });

    test('does not notify listeners when new value equals old value', () async {
      final notifier = Notifier<int>(10);
      int notificationCount = 0;

      // Add a listener that increments the notification count.
      notifier.addListener(() {
        notificationCount++;
      });

      // Set the same value; notification should not be triggered.
      notifier.value = 10;

      // Wait for microtasks.
      await Future.delayed(Duration.zero);

      expect(notificationCount, equals(0));
    });
  });
}
