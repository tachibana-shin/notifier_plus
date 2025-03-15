import 'package:flutter/material.dart';

import 'utils/one_call_task.dart';

/// A widget that rebuilds itself based on the latest changes in a list of [ChangeNotifier] dependencies.
/// 
/// The [WatchNotifier] listens to a list of [ChangeNotifier]s provided in the [depends] field.
/// It rebuilds its widget tree whenever any of the notifiers in the list emit a notification.
/// The [builder] callback is called to build the widget tree.
class WatchNotifier<T> extends StatefulWidget {
  /// The list of [ChangeNotifier]s that this widget depends on.
  final List<ChangeNotifier> depends;

  /// The builder function that constructs the widget tree.
  final Widget Function(BuildContext context) builder;

  /// Creates a [WatchNotifier] widget.
  ///
  /// The [depends] and [builder] parameters must not be null.
  const WatchNotifier({
    super.key,
    required this.depends,
    required this.builder,
  });

  @override
  State<WatchNotifier> createState() => _WatchNotifierState<T>();
}

class _WatchNotifierState<T> extends State<WatchNotifier<T>> {
  late Listenable _listenable;
  late final VoidCallback _refresh;

  @override
  void initState() {
    super.initState();

    late final VoidCallback refreshRoot;
    refreshRoot = () => setState(() {});

    _refresh = oneCallTask(refreshRoot);
    _setupListeners();
  }

  void _setupListeners() {
    _listenable = Listenable.merge(widget.depends)..addListener(_refresh);
  }

  void _unSetupListeners() {
    _listenable.removeListener(_refresh);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.depends != widget.depends) {
      _unSetupListeners();
      _setupListeners();
    }
  }

  @override
  void dispose() {
    _unSetupListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
