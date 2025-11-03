import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'crossvault_platform.dart';

/// An implementation of [CrossvaultPlatform] that uses method channels.
class MethodChannelCrossvault extends CrossvaultPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('crossvault');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
