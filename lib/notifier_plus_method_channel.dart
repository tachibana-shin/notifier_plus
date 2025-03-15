import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'notifier_plus_platform_interface.dart';

/// An implementation of [NotifierPlusPlatform] that uses method channels.
class MethodChannelNotifierPlus extends NotifierPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('notifier_plus');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
