import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'notifier_plus_method_channel.dart';

abstract class NotifierPlusPlatform extends PlatformInterface {
  /// Constructs a NotifierPlusPlatform.
  NotifierPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static NotifierPlusPlatform _instance = MethodChannelNotifierPlus();

  /// The default instance of [NotifierPlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelNotifierPlus].
  static NotifierPlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NotifierPlusPlatform] when
  /// they register themselves.
  static set instance(NotifierPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
