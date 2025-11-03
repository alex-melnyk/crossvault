import 'package:crossvault_platform_interface/src/method_channel_crossvault.dart';
import 'package:crossvault_platform_interface/src/options/crossvault_options.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of crossvault must implement.
///
/// Platform implementations should extend this class rather than implement it as `crossvault`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [CrossvaultPlatform] methods.
abstract class CrossvaultPlatform extends PlatformInterface {
  /// Constructs a CrossvaultPlatform.
  CrossvaultPlatform() : super(token: _token);

  static final Object _token = Object();

  static CrossvaultPlatform _instance = MethodChannelCrossvault();

  /// The default instance of [CrossvaultPlatform] to use.
  ///
  /// Defaults to [MethodChannelCrossvault].
  static CrossvaultPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CrossvaultPlatform] when
  /// they register themselves.
  static set instance(CrossvaultPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the platform version.
  ///
  /// This is a demo method and should be replaced with actual vault functionality.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  /// Checks if a key exists in the secure storage.
  ///
  /// Returns `true` if the key exists, `false` otherwise.
  ///
  /// [key] The key to check for existence.
  /// [options] Platform-specific options (IOSOptions, MacOSOptions, AndroidOptions, WindowsOptions).
  Future<bool> existsKey(String key, {CrossvaultOptions? options}) {
    throw UnimplementedError('existsKey() has not been implemented.');
  }

  /// Retrieves a value from the secure storage.
  ///
  /// Returns the value associated with the key, or `null` if not found.
  ///
  /// [key] The key to retrieve the value for.
  /// [options] Platform-specific options (IOSOptions, MacOSOptions, AndroidOptions, WindowsOptions).
  Future<String?> getValue(String key, {CrossvaultOptions? options}) {
    throw UnimplementedError('getValue() has not been implemented.');
  }

  /// Stores a value in the secure storage.
  ///
  /// [key] The key to store the value under.
  /// [value] The value to store.
  /// [options] Platform-specific options (IOSOptions, MacOSOptions, AndroidOptions, WindowsOptions).
  Future<void> setValue(
    String key,
    String value, {
    CrossvaultOptions? options,
  }) {
    throw UnimplementedError('setValue() has not been implemented.');
  }

  /// Deletes a value from the secure storage.
  ///
  /// [key] The key to delete.
  /// [options] Platform-specific options (IOSOptions, MacOSOptions, AndroidOptions, WindowsOptions).
  Future<void> deleteValue(String key, {CrossvaultOptions? options}) {
    throw UnimplementedError('deleteValue() has not been implemented.');
  }

  /// Deletes all values from the secure storage.
  ///
  /// [options] Platform-specific options (IOSOptions, MacOSOptions, AndroidOptions, WindowsOptions).
  Future<void> deleteAll({CrossvaultOptions? options}) {
    throw UnimplementedError('deleteAll() has not been implemented.');
  }
}
