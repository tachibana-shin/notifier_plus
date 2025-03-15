import 'package:flutter/foundation.dart';
import 'utils/one_call_task.dart';

/// A [ChangeNotifier] that wraps a value and notifies listeners when the value changes.
///
/// The [Notifier] extends [ChangeNotifier] and implements [ValueListenable],
/// allowing it to be used in places where a [ValueListenable] is required.
///
/// When the value is replaced with something that is not equal to the old
/// value as evaluated by the equality operator `==`, this class notifies its
/// listeners.
class Notifier<T> extends ChangeNotifier implements ValueListenable<T> {
  late final VoidCallback _onChange;

  /// Creates a [Notifier] that wraps the given value.
  ///
  /// If [kFlutterMemoryAllocationsEnabled] is true, it will dispatch an
  /// object creation event for debugging memory allocations.
  Notifier(this._value) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
    _onChange = oneCallTask(notifyListeners);
  }

  /// The current value stored in this notifier.
  @override
  T get value => _value;
  T _value;

  /// Sets a new value and notifies listeners if the new value is not equal
  /// to the current value.
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    _onChange();
  }

  /// Returns a string representation of the notifier, including its identity
  /// and the current value.
  @override
  String toString() => '${describeIdentity(this)}($value)';
}
