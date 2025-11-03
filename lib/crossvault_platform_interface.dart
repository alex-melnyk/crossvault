import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'crossvault_method_channel.dart';

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
