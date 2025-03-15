import 'package:flutter_test/flutter_test.dart';
import 'package:notifier_plus/notifier_plus.dart';
import 'package:notifier_plus/notifier_plus_platform_interface.dart';
import 'package:notifier_plus/notifier_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNotifierPlusPlatform
    with MockPlatformInterfaceMixin
    implements NotifierPlusPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NotifierPlusPlatform initialPlatform = NotifierPlusPlatform.instance;

  test('$MethodChannelNotifierPlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNotifierPlus>());
  });

  test('getPlatformVersion', () async {
    NotifierPlus notifierPlusPlugin = NotifierPlus();
    MockNotifierPlusPlatform fakePlatform = MockNotifierPlusPlatform();
    NotifierPlusPlatform.instance = fakePlatform;

    expect(await notifierPlusPlugin.getPlatformVersion(), '42');
  });
}
