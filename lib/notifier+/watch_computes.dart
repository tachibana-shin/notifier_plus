import 'package:flutter/material.dart';
import 'computed_notifier.dart';

import 'utils/one_call_task.dart';

/// A widget that builds itself based on the latest values emitted by a
/// list of [ComputedNotifier].
///
/// The values are retrieved from the [ComputedNotifier]s when this widget
/// is first built, and then again whenever any of the
/// [ComputedNotifier]s emit a new value. The [builder] callback is called
/// with the latest value from the [ComputedNotifier]s whenever this widget
/// needs to be rebuilt.
///
/// This widget is useful for building widgets that depend on the values of
/// multiple [ComputedNotifier]s.
class WatchComputes<T> extends StatefulWidget {
  final List<ComputedNotifier<T>> computes;
  final Widget Function(BuildContext context) builder;

  const WatchComputes({
    super.key,
    required this.computes,
    required this.builder,
  });

  @override
  State<WatchComputes> createState() => _WatchComputesState<T>();
}

class _WatchComputesState<T> extends State<WatchComputes<T>> {
  late final VoidCallback _refresh;

  @override
  void initState() {
    super.initState();

    _refresh = oneCallTask(() => setState(() {}));
    for (final computed in widget.computes) {
      computed.addListener(_refresh);
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.computes != widget.computes) {
      for (final computed in oldWidget.computes) {
        computed.removeListener(_refresh);
      }
      for (final computed in widget.computes) {
        computed.addListener(_refresh);
      }
    }
  }

  @override
  void dispose() {
    for (final computed in widget.computes) {
      computed.removeListener(_refresh);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
