import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// Import your oneCallTask function from its file.
// import 'package:your_package/path/to/one_call_task.dart';

VoidCallback oneCallTask(VoidCallback callback) {
  Future<void>? microtask;

  return () {
    if (microtask != null) return;
    microtask = Future.microtask(callback).whenComplete(() => microtask = null);
  };
}

void main() {
  test('oneCallTask executes callback only once per microtask', () async {
    int callCount = 0;

    // Define a simple callback that increments callCount.
    void callback() {
      callCount++;
    }

    // Wrap the callback using oneCallTask.
    final wrappedCallback = oneCallTask(callback);

    // Call the wrapped callback multiple times synchronously.
    // 同期的に複数回呼び出しても、コールバックは1回だけ実行されるはずです。
    wrappedCallback();
    wrappedCallback();
    wrappedCallback();

    // At this point, the callback has not executed yet because it is scheduled as a microtask.
    expect(callCount, equals(0));

    // Wait for microtasks to complete.
    await Future.microtask(() {});

    // After the microtask completes, the callback should have been executed only once.
    expect(callCount, equals(1));

    // Call the wrapped function again after the previous microtask is complete.
    wrappedCallback();
    wrappedCallback();
    await Future.microtask(() {});

    // The callback should have executed one more time.
    expect(callCount, equals(2));
  });
}
