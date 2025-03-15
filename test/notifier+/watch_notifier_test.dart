import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/notifier+/watch_notifier.dart';

void main() {
  group('WatchNotifier', () {
    testWidgets('rebuilds when any dependency changes', (WidgetTester tester) async {
      // Create a dependency using ValueNotifier.
      final valueNotifier = ValueNotifier<int>(0);

      // Build the widget tree using WatchNotifier.
      await tester.pumpWidget(
        MaterialApp(
          home: WatchNotifier<int>(
            depends: [valueNotifier],
            builder: (context) {
              // The builder reads the current value from the dependency.
              return Text(
                valueNotifier.value.toString(),
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      );

      // Verify the initial text.
      expect(find.text('0'), findsOneWidget);

      // Update the dependency's value.
      valueNotifier.value = 42;

      // Let the oneCallTask microtask and widget rebuild process complete.
      await tester.pumpAndSettle();

      // Verify that the widget rebuilds with the updated value.
      expect(find.text('42'), findsOneWidget);

      // Change the dependency again.
      valueNotifier.value = 100;
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
    });
  });
}
