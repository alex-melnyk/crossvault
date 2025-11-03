import 'package:crossvault_platform_interface/crossvault_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The macOS implementation of [CrossvaultPlatform].
class CrossvaultMacos extends CrossvaultPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('crossvault');

  /// Registers this class as the default instance of [CrossvaultPlatform]
  static void registerWith() {
    CrossvaultPlatform.instance = CrossvaultMacos();
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
