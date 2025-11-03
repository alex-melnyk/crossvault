import 'package:flutter_test/flutter_test.dart';
import 'package:crossvault/crossvault.dart';
import 'package:crossvault_platform_interface/crossvault_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCrossvaultPlatform
    with MockPlatformInterfaceMixin
    implements CrossvaultPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CrossvaultPlatform initialPlatform = CrossvaultPlatform.instance;

  test('$MethodChannelCrossvault is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCrossvault>());
  });

  test('getPlatformVersion', () async {
    Crossvault crossvaultPlugin = Crossvault();
    MockCrossvaultPlatform fakePlatform = MockCrossvaultPlatform();
    CrossvaultPlatform.instance = fakePlatform;

    expect(await crossvaultPlugin.getPlatformVersion(), '42');
  });
}
