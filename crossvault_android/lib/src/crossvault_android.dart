import 'package:crossvault_platform_interface/crossvault_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Android implementation of [CrossvaultPlatform].
class CrossvaultAndroid extends CrossvaultPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('crossvault');

  /// Registers this class as the default instance of [CrossvaultPlatform]
  static void registerWith() {
    CrossvaultPlatform.instance = CrossvaultAndroid();
  }

  @override
  Future<bool> existsKey(
    String key, {
    CrossvaultOptions? options,
  }) async {
    final result = await methodChannel.invokeMethod<bool>(
      'existsKey',
      _buildArguments(key: key, options: options),
    );
    return result ?? false;
  }

  @override
  Future<String?> getValue(
    String key, {
    CrossvaultOptions? options,
  }) async {
    final result = await methodChannel.invokeMethod<String>(
      'getValue',
      _buildArguments(key: key, options: options),
    );
    return result;
  }

  @override
  Future<void> setValue(
    String key,
    String value, {
    CrossvaultOptions? options,
  }) async {
    await methodChannel.invokeMethod<void>(
      'setValue',
      _buildArguments(key: key, value: value, options: options),
    );
  }

  @override
  Future<void> deleteValue(
    String key, {
    CrossvaultOptions? options,
  }) async {
    await methodChannel.invokeMethod<void>(
      'deleteValue',
      _buildArguments(key: key, options: options),
    );
  }

  @override
  Future<void> deleteAll({
    CrossvaultOptions? options,
  }) async {
    await methodChannel.invokeMethod<void>(
      'deleteAll',
      _buildArguments(options: options),
    );
  }

  /// Builds method arguments from key, value, and Android-specific options.
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

    // Extract Android-specific options
    if (options is AndroidOptions) {
      args['sharedPreferencesName'] = options.sharedPreferencesName;
      args['resetOnError'] = options.resetOnError;
    }

    return args;
  }
}
