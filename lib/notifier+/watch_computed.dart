import 'package:flutter/material.dart';
import 'computed_notifier.dart';

/// A widget that builds itself based on the latest value emitted by a
/// [ComputedNotifier].
///
/// The value is retrieved from the [ComputedNotifier] when this widget is first
/// built, and then again whenever the [ComputedNotifier] emits a new value. The
/// [builder] callback is called with the latest value from the
/// [ComputedNotifier] whenever this widget needs to be rebuilt.
///
/// This widget is useful for building widgets that depend on the value of a
/// [ComputedNotifier].
class WatchComputed<T> extends StatefulWidget {
  final ComputedNotifier<T> computed;
  final Widget Function(BuildContext context, T value) builder;

  const WatchComputed({
    super.key,
    required this.builder,
    required this.computed,
  });

  @override
  State<WatchComputed> createState() => _WatchComputedState<T>();
}

class _WatchComputedState<T> extends State<WatchComputed<T>> {
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
