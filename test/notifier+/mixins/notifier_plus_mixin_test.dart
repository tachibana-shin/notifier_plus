import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/notifier+/mixins/notifier_plus_mixin.dart';

/// Dummy ChangeNotifier for testing.
class DummyNotifier extends ChangeNotifier {
  void trigger() {
    notifyListeners();
  }
}

/// Test widget that uses [NotifierPlusMixin].
class TestWidget extends StatefulWidget {
  final ChangeNotifier notifier;
  final VoidCallback onUnload;

  const TestWidget({
    required this.notifier,
    required this.onUnload,
    super.key,
  });

  @override
  createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> with NotifierPlusMixin {
  int counter = 0;

  @override
  void initState() {
    super.initState();
    // Listen to the notifier and increment counter when notified.
    // リスナーが呼ばれると、counter をインクリメントします。
    listenNotifier(widget.notifier, () {
      counter++;
    });

    // Register a callback to be executed before widget is disposed.
    // ウィジェットが破棄される前に呼ばれるコールバックを登録します。
    onBeforeUnload(widget.onUnload);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void main() {
  testWidgets('NotifierPlusMixin: Listener is called correctly and cleanup works', (WidgetTester tester) async {
    final notifier = DummyNotifier();
    int onUnloadCalled = 0;

    // Create test widget with the dummy notifier.
    final testWidget = MaterialApp(
      home: TestWidget(
        notifier: notifier,
        onUnload: () {
          onUnloadCalled++;
        },
      ),
    );

    // Build the widget tree.
    await tester.pumpWidget(testWidget);

    // Verify initial counter value is 0.
    final state = tester.state<_TestWidgetState>(find.byType(TestWidget));
    expect(state.counter, equals(0));

    // Trigger the notifier and pump the widget to process the microtask.
    notifier.trigger();
    await tester.pump();
    expect(state.counter, equals(1));

    // Trigger the notifier twice in quick succession.
    notifier.trigger();
    notifier.trigger();
    await tester.pump();
    // Expect the listener to be called once per trigger.
    expect(state.counter, equals(2));

    // Dispose the widget by pumping a new widget.
    await tester.pumpWidget(Container());
    // Verify that onBeforeUnload callback was called exactly once.
    expect(onUnloadCalled, equals(1));
  });
}
