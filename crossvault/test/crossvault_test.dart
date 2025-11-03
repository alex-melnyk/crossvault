import 'package:flutter_test/flutter_test.dart';
import 'package:crossvault/crossvault.dart';
import 'package:crossvault_platform_interface/crossvault_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCrossvaultPlatform
    with MockPlatformInterfaceMixin
    implements CrossvaultPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> existsKey(String key, {CrossvaultOptions? options}) => Future.value(true);

  @override
  Future<String?> getValue(String key, {CrossvaultOptions? options}) => Future.value('test_value');

  @override
  Future<void> setValue(String key, String value, {CrossvaultOptions? options}) => Future.value();

  @override
  Future<void> deleteValue(String key, {CrossvaultOptions? options}) => Future.value();

  @override
  Future<void> deleteAll({CrossvaultOptions? options}) => Future.value();
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

  group('Global configuration', () {
    late MockCrossvaultPlatform fakePlatform;

    setUp(() {
      Crossvault.reset();
      fakePlatform = MockCrossvaultPlatform();
      CrossvaultPlatform.instance = fakePlatform;
    });

    tearDown(() {
      Crossvault.reset();
    });

    test('init and reset work correctly', () async {
      // Init should not throw
      await Crossvault.init(
        options: IOSOptions(
          accessGroup: 'test.group',
          synchronizable: true,
        ),
      );

      // Reset should not throw
      Crossvault.reset();
    });

    test('can call methods after init', () async {
      await Crossvault.init(
        options: IOSOptions(accessGroup: 'test.group'),
      );

      final crossvault = Crossvault();
      
      // Should not throw
      await crossvault.setValue('key', 'value');
      final value = await crossvault.getValue('key');
      expect(value, 'test_value');
    });

    test('can override global options in method call', () async {
      await Crossvault.init(
        options: IOSOptions(
          accessGroup: 'global.group',
          synchronizable: false,
        ),
      );

      final crossvault = Crossvault();
      
      // Should not throw when overriding
      await crossvault.setValue(
        'key',
        'value',
        options: IOSOptions(
          accessGroup: 'override.group',
          synchronizable: true,
        ),
      );
    });
  });

  group('Options merge', () {
    test('IOSOptions merge works correctly', () {
      final base = IOSOptions(
        accessGroup: 'base.group',
        synchronizable: false,
        accessibility: IOSAccessibility.afterFirstUnlock,
      );

      final override = IOSOptions(
        accessGroup: 'override.group',
        synchronizable: true,
        accessibility: IOSAccessibility.whenUnlocked,
      );

      final merged = base.merge(override);
      expect(merged, isA<IOSOptions>());
      final iosOptions = merged as IOSOptions;
      expect(iosOptions.accessGroup, 'override.group');
      expect(iosOptions.synchronizable, true);
      expect(iosOptions.accessibility, IOSAccessibility.whenUnlocked);
    });

    test('IOSOptions merge with null returns original', () {
      final base = IOSOptions(accessGroup: 'base.group');
      final merged = base.merge(null);
      expect(merged, same(base));
    });

    test('IOSOptions merge with different type returns original', () {
      final base = IOSOptions(accessGroup: 'base.group');
      final android = AndroidOptions();
      final merged = base.merge(android);
      expect(merged, same(base));
    });
  });
}
