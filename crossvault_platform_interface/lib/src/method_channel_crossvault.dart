import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'crossvault_options.dart';
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

  @override
  Future<bool> existsKey(String key, {CrossvaultOptions? options}) async {
    final result = await methodChannel.invokeMethod<bool>(
      'existsKey',
      _buildArguments(key: key, options: options),
    );
    return result ?? false;
  }

  @override
  Future<String?> getValue(String key, {CrossvaultOptions? options}) async {
    final result = await methodChannel.invokeMethod<String>(
      'getValue',
      _buildArguments(key: key, options: options),
    );
    return result;
  }

  @override
  Future<void> setValue(String key, String value, {CrossvaultOptions? options}) async {
    await methodChannel.invokeMethod<void>(
      'setValue',
      _buildArguments(key: key, value: value, options: options),
    );
  }

  @override
  Future<void> deleteValue(String key, {CrossvaultOptions? options}) async {
    await methodChannel.invokeMethod<void>(
      'deleteValue',
      _buildArguments(key: key, options: options),
    );
  }

  @override
  Future<void> deleteAll({CrossvaultOptions? options}) async {
    await methodChannel.invokeMethod<void>(
      'deleteAll',
      _buildArguments(options: options),
    );
  }

  /// Builds method arguments from key, value, and platform-specific options.
  Map<String, dynamic> _buildArguments({
    String? key,
    String? value,
    CrossvaultOptions? options,
  }) {
    final Map<String, dynamic> args = {};

    if (key != null) {
      args['key'] = key;
    }

    if (value != null) {
      args['value'] = value;
    }

    // Extract platform-specific options
    if (options != null) {
      if (options is IOSOptions) {
        args['accessGroup'] = options.accessGroup;
        args['synchronizable'] = options.synchronizable;
        args['accessibility'] = options.accessibility.name;
      } else if (options is MacOSOptions) {
        args['accessGroup'] = options.accessGroup;
        args['synchronizable'] = options.synchronizable;
        args['accessibility'] = options.accessibility.name;
      } else if (options is AndroidOptions) {
        args['sharedPreferencesName'] = options.sharedPreferencesName;
        args['resetOnError'] = options.resetOnError;
      } else if (options is WindowsOptions) {
        args['prefix'] = options.prefix;
        args['persist'] = options.persist.name;
      }
    }

    return args;
  }
}
