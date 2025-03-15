import 'package:flutter/material.dart';
import 'computed_async_notifier.dart';

/// A widget that builds itself based on the latest value emitted by a
/// [ComputedAsyncNotifier].
///
/// The value is retrieved from the [ComputedAsyncNotifier] when this widget
/// is first built, and then again whenever the [ComputedAsyncNotifier] emits
/// a new value. The [builder] callback is called with the latest value
/// from the [ComputedAsyncNotifier] whenever this widget needs to be rebuilt.
///
/// This widget is useful for building widgets that depend on the value of a
/// [ComputedAsyncNotifier].
class WatchAsyncComputed<T> extends StatefulWidget {
  /// The [ComputedAsyncNotifier] whose value this widget depends on.
  final ComputedAsyncNotifier<T> computed;

  /// A callback that is called with the latest value from the [ComputedAsyncNotifier]
  /// whenever this widget needs to be rebuilt.
  final Widget Function(BuildContext context, T? value) builder;

  /// Creates a new [WatchAsyncComputed].
  ///
  /// The [computed] parameter must not be null.
  ///
  /// The [builder] parameter must not be null.
  const WatchAsyncComputed({
    super.key,
    required this.builder,
    required this.computed,
  });

  @override
  State<WatchAsyncComputed> createState() => _WatchAsyncComputedState<T>();
}

class _WatchAsyncComputedState<T> extends State<WatchAsyncComputed<T>> {
  @override
  void initState() {
    super.initState();
    widget.computed.addListener(_refresh);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.computed != widget.computed) {
      oldWidget.computed.removeListener(_refresh);
      widget.computed.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.computed.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.computed.value);
  }
}
