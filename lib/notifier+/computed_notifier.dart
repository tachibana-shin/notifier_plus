import 'package:flutter/foundation.dart';
import 'utils/one_call_task.dart';

/// A [ChangeNotifier] that computes a value from a function.
///
/// The value is computed when it is first requested, and then re-computed
/// whenever any of the notifiers in [depends] change. If
/// [onBeforeUpdate] is provided, it is called before re-computing the value.
///
/// If the computation throws, the error is stored and the value remains null.
/// If [onError] is provided, it is called with the error.
class ComputedNotifier<T> extends ChangeNotifier {
  late T _value;

  final T Function() compute;
  final List<ChangeNotifier> depends;

  bool _initialized = false;
  Listenable? _listenable;
  late final VoidCallback _onChange;

  /// Creates a [ComputedNotifier].
  ///
  /// The [compute] function should return the value.
  ///
  /// The [depends] list should contain all of the notifiers that the value
  /// depends on.
  ComputedNotifier(this.compute, {required this.depends}) {
    _onChange = oneCallTask(() {
      _value = compute();
      notifyListeners();
    });
  }

  /// The value of this [ComputedNotifier].
  ///
  /// If the value has not yet been computed, then this getter will compute the
  /// value, set it, and notify all of the listeners.
  T get value {
    if (!_initialized) {
      _initialized = true;
      _value = this.compute();
      _listenable = Listenable.merge(depends)..addListener(_onChange);
    }

    return _value;
  }

  /// Force the value to be a specific value.
  ///
  /// This setter will override the [compute] function.
  void forceValue(T value) {
    _value = value;
    notifyListeners();
  }

  /// Dispose of this [ComputedNotifier].
  ///
  /// This will remove the listener from the [depends] list.
  @override
  void dispose() {
    _listenable?.removeListener(_onChange);
    super.dispose();
  }

  /// A string representation of this [ComputedNotifier].
  ///
  /// This will be in the form of "ComputedNotifier<type>(value)".
  @override
  String toString() => '${describeIdentity(this)}($value)';
}
