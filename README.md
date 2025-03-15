# notifier_plus

**notifier_plus** is a high-performance Flutter state management library designed to optimize `Listenable` updates.
Created by **tachibana-shin**, this library eliminates unnecessary UI rebuilds caused by `ValueNotifier` and `Listenable.merge`.

---

## 📖 Table of Contents
- [Why notifier_plus?](#why-notifier_plus)
- [Installation](#installation)
- [Core Classes](#core-classes)
  - [`Notifier<T>` - Optimized ValueNotifier](#notifiert---optimized-valuenotifier)
  - [`ComputedNotifier<T>` - Derived State Management](#computednotifiert---derived-state-management)
  - [`ComputedAsyncNotifier<T>` - Async Computed State](#computedasyncnotifiert---async-computed-state)
- [Watch Widgets](#watch-widgets)
- [Utilities](#utilities)
- [Comparison Table](#comparison-table)
- [Contributing](#contributing)
- [License](#license)

---

## 📌 Why `notifier_plus`?

### 🚀 The Problem with `ValueNotifier` and `Listenable.merge`

- `ValueNotifier` causes redundant UI rebuilds when updated consecutively:
  ```dart
  a.value++;
  a.value++;  // Causes two rebuilds, but only one is needed
  ```

- `Listenable.merge` invokes multiple rebuilds when multiple dependencies update:
  ```dart
  a.value++;
  b.value++;  // Triggers two rebuilds instead of one
  ```

### ✅ Solution: `notifier_plus`

- **Batches multiple updates within the same frame** to trigger only one rebuild.
- **Efficient state management** that reduces unnecessary UI updates.
- **Easy to use** with `ValueNotifier`-like API but optimized for performance.

---

## 📦 Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  notifier_plus:
    git:
      url: https://github.com/tachibana-shin/notifier_plus.git
```

Import it:

```dart
import 'package:notifier_plus/notifier_plus.dart';
```

---

## 🟢 Core Classes

### `Notifier<T>` - Optimized `ValueNotifier`

A `ChangeNotifier` implementation that ensures updates are only triggered **once per frame**.

```dart
final counter = Notifier<int>(0);
counter.addListener(() {
  print("Counter updated: ${counter.value}");
});
counter.value++;  // Only one listener call per frame
```

✅ Features:
- Prevents redundant updates.
- Implements `ValueListenable<T>` for seamless integration.

---

### `ComputedNotifier<T>` - Derived State Management

Computes a value based on other `Notifier` dependencies.

```dart
final a = Notifier<int>(1);
final b = Notifier<int>(2);
final sum = ComputedNotifier(() => a.value + b.value, depends: [a, b]);

sum.addListener(() {
  print("Sum updated: ${sum.value}");
});
```

✅ Features:
- Automatically tracks dependencies.
- Only updates when dependent values change.

---

### `ComputedAsyncNotifier<T>` - Async Computed State

Handles derived state that depends on asynchronous computations.

```dart
final asyncSum = ComputedAsyncNotifier<int>(
  () async => await fetchData(),
  depends: [a, b]
);
```

✅ Features:
- Supports async state calculations.
- Notifies listeners only when computation completes.

---

## 🏗 Watch Widgets

Efficient UI rebuilding for state changes.

### `WatchComputed<T>` - Watches a Single `ComputedNotifier`
```dart
WatchComputed<int>(
  computed: sum,
  builder: (context, value) {
    return Text("Sum: $value");
  },
);
```

### `WatchAsyncComputed<T>` - Watches an Async Computed Value
```dart
WatchAsyncComputed<int>(
  computed: asyncSum,
  builder: (context, value) {
    return value == null ? CircularProgressIndicator() : Text("Sum: $value");
  },
);
```

### `WatchComputes<T>` - Watches Multiple `ComputedNotifier`s
```dart
WatchComputes<int>(
  computes: [a, b],
  builder: (context) {
    return Text("A: ${a.value}, B: ${b.value}");
  },
);
```

### `WatchNotifier<T>` - Watches Multiple `ChangeNotifier`s
```dart
WatchNotifier(
  depends: [a, b],
  builder: (context) {
    return Text("State changed: A=${a.value}, B=${b.value}");
  },
);
```

---

## ⚡ Utilities

### `oneCallTask(VoidCallback callback)`

A helper function to debounce state updates within the same frame.

```dart
final debouncedUpdate = oneCallTask(() {
  print("Updated!");
});
debouncedUpdate(); // Calls once per frame
```

### `watch(List<Listenable> depends, VoidCallback callback, {bool immediate})`

Registers a callback that listens to multiple `Listenable`s efficiently.

```dart
watch([a, b], () {
  print("A or B changed");
});
```

---

## 📌 Comparison Table

| Feature                             | `notifier_plus` |
| ----------------------------------- | ------------- |
| Prevents redundant UI rebuilds      | ✅            |
| Optimized `ValueNotifier` replacement | ✅            |
| Efficient dependency tracking       | ✅            |
| Supports async computed values      | ✅            |
| Lightweight & easy to use           | ✅            |

---

## 🛠 Contributing

Pull requests are welcome! Feel free to submit issues or feature requests.

## 📜 License

MIT License. See [LICENSE](LICENSE) for details.

