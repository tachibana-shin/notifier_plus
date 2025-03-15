import 'dart:collection';
import 'package:flutter/widgets.dart';
import '../utils/one_call_task.dart';

/// A mixin that provides utilities for managing listeners and handling cleanup
/// in a [StatefulWidget].
///
/// This mixin can be used to add and manage listeners to [ChangeNotifier]s,
/// and provides a mechanism for executing callbacks before the widget is
/// disposed.
mixin NotifierPlusMixin<T extends StatefulWidget> on State<T> {
  final _listenersStore = HashMap<Listenable, VoidCallback>();
  final _fbBeforeUnloadStore = <VoidCallback>{};

  /// Adds a listener to a [ChangeNotifier]. Optionally, the listener can be
  /// invoked immediately.
  ///
  /// The listener is wrapped in a `oneCallTask` to ensure it is only executed
  /// once per microtask.
  ///
  /// - [notifier]: The [ChangeNotifier] to listen to.
  /// - [listener]: The callback to execute when the notifier changes.
  /// - [immediate]: If true, the listener is called immediately.
  void listenNotifier(ChangeNotifier notifier, VoidCallback listener,
      {bool immediate = false}) {
    listener = oneCallTask(listener);

    if (immediate) listener();
    notifier.addListener(listener);
    _listenersStore[notifier] = listener;
  }

  /// Adds a listener to multiple [ChangeNotifier]s. Optionally, the listener
  /// can be invoked immediately.
  ///
  /// The listener is wrapped in a `oneCallTask` to ensure it is only executed
  /// once per microtask.
  ///
  /// - [notifiers]: A list of [ChangeNotifier]s to listen to.
  /// - [listener]: The callback to execute when any notifier changes.
  /// - [immediate]: If true, the listener is called immediately.
  void listenNotifiers(List<ChangeNotifier> notifiers, VoidCallback listener,
      {bool immediate = false}) {
    final notifier = Listenable.merge(notifiers);

    listener = oneCallTask(listener);

    if (immediate) listener();
    notifier.addListener(listener);
    _listenersStore[notifier] = listener;
  }

  /// Registers a callback to be executed before the widget is disposed.
  ///
  /// - [cb]: The callback to be executed.
  void onBeforeUnload(VoidCallback cb) {
    _fbBeforeUnloadStore.add(cb);
  }

  @override
  void dispose() {
    _fbBeforeUnloadStore
      ..forEach((cb) => cb())
      ..clear();
    _listenersStore
      ..forEach((notifier, listener) {
        notifier.removeListener(listener);
      })
      ..clear();

    super.dispose();
  }
}
