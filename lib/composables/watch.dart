import 'package:flutter/foundation.dart';

import '../notifier+/utils/one_call_task.dart';

/// Registers a callback to be executed when any of the [Listenable]s
/// in [depends] change. Optionally, the callback can be invoked
/// immediately.
///
/// The callback is wrapped in a `oneCallTask` to ensure it is only executed
/// once per microtask.
///
/// - [depends]: A list of [Listenable]s to listen to.
/// - [callback]: The callback to execute when any of the [Listenable]s change.
/// - [immediate]: If true, the callback is called immediately.
///
/// Returns a callback that can be used to unregister the listener.
VoidCallback watch(List<Listenable> depends, VoidCallback callback,
    {bool immediate = false}) {
  final notifier = Listenable.merge(depends);

  callback = oneCallTask(callback);

  if (immediate) callback();
  notifier.addListener(callback);

  return () => notifier.removeListener(callback);
}
