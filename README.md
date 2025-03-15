
# Notifier Plus

Notifier Plus is a Flutter plugin designed to simplify building reactive data patterns, manage notifications, and address the shortcomings of vanilla [Listenable.merge] and [ValueNotifier]. In particular, it prevents unnecessary rebuild calls that occur when consecutive updates trigger redundant UI rebuilds.

For example, with a standard [ValueNotifier] approach, doing:
```dart
a.value++;
a.value++;
```
would typically cause the builder in a [ValueListenableBuilder] to rebuild twice—even though only the final state is meaningful. Similarly, with [Listenable.merge], doing:
```dart
a.value++;
b.value++;
```
would result in two separate builder calls. Notifier Plus avoids these inefficiencies by batching and harmonizing rapid-fire updates.

---

## Features

- Reactive data management through various **specialized notifiers**:
  - [ComputedNotifier] for synchronous computations.
  - [ComputedAsyncNotifier] for async tasks (especially with delayed or future-based states).
  - [Notifier] for straightforward reactive state updates.
- **Composable watchers** to observe both synchronous and asynchronous changes, like `watch`, `watchComputed`, and `watchAsyncComputed`.
- **Task utilities** like [OneCallTask], which batch repeated function calls into a single execution.
- **Mixins** such as [NotifierPlusMixin], easily adding plugin functionalities to your classes.
- A specialized **[WatchNotifier]** widget that merges multiple `ChangeNotifier` instances without causing multiple redundant rebuild calls.

---

## Motivation: Overcoming Redundant Rebuilds

One of the primary reasons for creating Notifier Plus is to eliminate excessive rebuild calls that occur with default Flutter classes like `Listenable.merge` or consecutive `ValueNotifier` increments. For instance, performing multiple increments (`a.value++`, `b.value++`) might prompt multiple distinct rebuilds. By contrast, Notifier Plus batches these triggers so that your UI only updates once, capturing the final, aggregated state.

---

## Project Structure

- **lib/notifier_plus.dart**  
  A central export file that re-exports all core classes and utilities:
  ```dart
  export 'composables/watch.dart';
  export 'notifier+/mixins/notifier_plus_mixin.dart';
  export 'notifier+/utils/one_call_task.dart';
  export 'notifier+/computed_async_notifier.dart';
  export 'notifier+/computed_notifier.dart';
  export 'notifier+/notifier.dart';
  export 'notifier+/watch_async_computed.dart';
  export 'notifier+/watch_computed.dart';
  export 'notifier+/watch_computes.dart';
  export 'notifier+/watch_notifier.dart';
  ```

Below is an overview of the contents of these exported files, along with sample usage of the major functionalities.

### Exported Items

1. **watch.dart**  
   - `watch<T>`: Observes changes in the given `Notifier<T>` or `ValueNotifier<T>` and executes a callback.  
     Example:
     ```dart
     final myNotifier = Notifier<int>(initialValue: 0);
     
     watch<int>(myNotifier, (value) {
       print('Notifier updated: $value');
     });
     
     myNotifier.value++;
     ```
   - `watchComputed<T>`: Similar to `watch<T>`, but for `ComputedNotifier<T>` instances—ideal for derived or computed states.

2. **mixins/notifier_plus_mixin.dart**  
   - `NotifierPlusMixin`: A mixin that you can add to your classes to automatically handle the attachment/detachment of listeners for multiple notifiers.

3. **utils/one_call_task.dart**  
   - `OneCallTask`: Batches repeated function calls into a single run. Useful for preventing spammy calls within the same frame/batch.  
     Example:
     ```dart
     final singleTask = OneCallTask(() {
       print("Executed only once if triggered multiple times in one batch!");
     });

     singleTask.invoke();
     singleTask.invoke(); // Subsequent calls within this batch won't trigger again
     ```

4. **computed_async_notifier.dart**  
   - `ComputedAsyncNotifier<T>`: Manages asynchronous states, such as fetching data from a server.  
     Example:
     ```dart
     final fetchNotifier = ComputedAsyncNotifier<int>((ref) async {
       // Simulate a network call
       await Future.delayed(Duration(seconds: 1));
       return 100;
     });

     // watchAsyncComputed (example usage)
     watchAsyncComputed<int>(fetchNotifier, (fetchedValue) {
       print('Fetched value: $fetchedValue');
     });
     ```

5. **computed_notifier.dart**  
   - `ComputedNotifier<T>`: Manages a synchronous “computed” state, typically derived from one or more notifiers.  
     Example:
     ```dart
     final a = Notifier<int>(initialValue: 0);
     final b = Notifier<int>(initialValue: 10);

     final sumNotifier = ComputedNotifier<int>(
       compute: () => a.value + b.value,
       initialValue: 0,
     );

     watchComputed<int>(sumNotifier, (sum) {
       print('Sum of a & b: $sum');
     });

     a.value = 5; // sumNotifier.value becomes 15, triggers watchComputed callback
     b.value = 20; // sumNotifier.value becomes 25
     ```

6. **notifier.dart**  
   - `Notifier<T>`: A straightforward reactive state holder exposing a `.value` property.  
     Example:
     ```dart
     final count = Notifier<int>(initialValue: 0);
     count.addListener(() {
       print('Count changed: ${count.value}');
     });
     count.value++; // prints "Count changed: 1"
     ```

7. **watch_async_computed.dart**  
   - `watchAsyncComputed<T>`: A convenience method for listening to changes emitted by a `ComputedAsyncNotifier<T>`.

8. **watch_computed.dart**  
   - `watchComputed<T>`: Listens to changes emitted by a `ComputedNotifier<T>`.

9. **watch_computes.dart**  
   - Similar to `watch_computed.dart`, but supports multiple computed values or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
lues or more advanced usage scenarios.

10. **watch_notifier.dart**  
    - `WatchNotifier`: A widget that takes a list of `ChangeNotifier` objects and rebuilds only once if any of them changes in quick succession.  
      Example:
      ```dart
      final a = ValueNotifier<int>(0);
      final b = ValueNotifier<int>(0);

      WatchNotifier(
        depends: [a, b],
        builder: (context) {
          // This widget rebuilds only once, even when 'a' and 'b' are updated rapidly
          return Text('a = ${a.value}, b = ${b.value}');
        },
      );

      // Doing:
      a.value++;
      b.value++;
      // triggers only a single rebuild
      ```

---

## Getting Started

1. **Install the Plugin**  
   In your app’s `pubspec.yaml`, add:
   ```yaml
   dependencies:
     notifier_plus:
       path: ../notifier_plus
       # Alternatively, from Git or pub.dev, depending on how you distribute the plugin
   ```

2. **Run Flutter Pub Get**  
   ```
   flutter pub get
   ```

3. **Add Platforms (If Needed)**  
   Currently, this plugin is generated by Flutter’s plugin template without any platforms configured by default. To add platforms like Android, iOS, etc.:
   ```bash
   flutter create -t plugin --platforms android,ios,linux,macos,windows .
   ```
   Make sure the `pubspec.yaml` contains the relevant list of `plugin:` platforms.

4. **Import and Use**  
   ```dart
   import 'package:notifier_plus/notifier_plus.dart';

   void main() {
     final counter = Notifier<int>(initialValue: 0);

     // Listen to changes
     counter.addListener(() {
       print('Value updated to: ${counter.value}');
     });

     // Trigger updates
     counter.value++;
     counter.value++;
   }
   ```

---

## Usage Examples

### Synchronous Data Tracking

```dart
final computedNotifier = ComputedNotifier<int>(
  compute: () => someValueNotifier.value + 1,
  initialValue: 0,
);

watchComputed<int>(computedNotifier, (newValue) {
  print('Updated synchronous computed value: $newValue');
});

// Update base notifier
someValueNotifier.value = 10;
// ComputedNotifier might re-compute to 11
```

### Asynchronous Data Tracking

```dart
final asyncNotifier = ComputedAsyncNotifier<String>((ref) async {
  // Simulate an HTTP request
  await Future.delayed(Duration(seconds: 1));
  return 'Fetched from server';
});

watchAsyncComputed<String>(asyncNotifier, (data) {
  print('Async data received: $data');
});
```

### Handling Rapid Calls with OneCallTask

```dart
final myOneCall = OneCallTask(() {
  print('Executed only once even if called multiple times quickly');
});

myOneCall.invoke();
myOneCall.invoke(); // No repeated execution in the same batch
```

### Avoiding Redundant Rebuilds with WatchNotifier

```dart
final notifyA = ValueNotifier<int>(0);
final notifyB = ValueNotifier<int>(0);

WatchNotifier(
  depends: [notifyA, notifyB],
  builder: (context) {
    // Rebuilds only once if both notifyA and notifyB are incremented simultaneously
    return Text('a = ${notifyA.value}, b = ${notifyB.value}');
  },
);
```

---

## Contributing

Contributions are welcome! Feel free to:
- Open Issues for bug reports or feature requests.
- Create Pull Requests to add or improve functionality.

---

## License

This project currently has no explicit license. Please check the `LICENSE` file (if present) in the repository for updated licensing details.

---

## Support

For any questions, suggestions, or further help, open an Issue on GitHub:
[GitHub – tachibana-shin/notifier_plus](https://github.com/tachibana-shin/notifier_plus)

Happy Coding with Notifier Plus!
