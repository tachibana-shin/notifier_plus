import 'package:flutter/foundation.dart';

import 'utils/one_call_task.dart';

/// A [ChangeNotifier] that computes a value from a future.
///
/// The future is computed when the value is first requested, and then
/// re-computed whenever any of the notifiers in [depends] change. If
/// [beforeUpdate] is provided, it is called before re-computing the value.
///
/// If the computation throws, the error is stored and the value remains null.
/// If [onError] is provided, it is called with the error.
class ComputedAsyncNotifier<T> extends ChangeNotifier {
  T? _value;
  dynamic _error;
  bool _loading = false;

  /// The future that computes the value.
  final Future<T> Function() compute;

  /// The notifiers that trigger a re-computation of the value when changed.
  final List<ChangeNotifier> depends;

  /// An optional callback to call when an error occurs.
  final void Function(dynamic error)? onError;

  /// An optional callback to call before re-computing the value.
  final T? Function()? beforeUpdate;

  late final VoidCallback _onChange;
  Listenable? _listenable;
  bool _initialized = false;

  ComputedAsyncNotifier(this.compute,
      {required this.depends, this.onError, this.beforeUpdate}) {
    _onChange = oneCallTask(() {
      _loading = true;

      if (beforeUpdate != null) {
        _value = beforeUpdate!();
      }

      _updateValue()
          .then((_) => notifyListeners())
          .catchError((error) => onError?.call(_error = error))
          .whenComplete(() => _loading = false);
    });
  }

  /// The value or null if it hasn't been computed yet.
  T? get value {
    if (!_initialized) {
      _initialized = true;

      _onChange();
      _listenable = Listenable.merge(depends)..addListener(_onChange);
    }

    return _value;
  }

  /// The error or null if no error has occurred.
  dynamic get error => _error;
  bool get loading => _loading;

  Future<void> _updateValue() async {
    _value = await compute();
  }

  /// Force the value to be a specific value.
  void forceValue(T value) {
    _value = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _listenable?.removeListener(_onChange);
    super.dispose();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
