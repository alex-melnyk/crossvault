import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_crossvault.dart';

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
}
