import 'package:flutter/foundation.dart';

VoidCallback oneCallTask(VoidCallback callback) {
  Future<void>? microtask;

  return () {
    if (microtask != null) return;
    microtask = Future.microtask(callback).whenComplete(() => microtask = null);
  };
}
