import 'package:crossvault_platform_interface/crossvault_platform_interface.dart';
import 'package:flutter/foundation.dart';

// Re-export options for convenience
export 'package:crossvault_platform_interface/crossvault_platform_interface.dart'
    show
        CrossvaultOptions,
        CrossvaultConfig,
        IOSOptions,
        MacOSOptions,
        AndroidOptions,
        WindowsOptions,
        IOSAccessibility,
        MacOSAccessibility,
        WindowsPersist;

/// The main Crossvault plugin class.
///
/// This provides a unified API for secure vault operations across
/// Android, iOS, macOS, and Windows platforms.
///
/// Example usage:
/// ```dart
/// // Initialize with global configuration (optional)
/// await Crossvault.init(
///   options: IOSOptions(
///     accessGroup: 'io.alexmelnyk.crossvault.shared',
///     synchronizable: true,
///   ),
/// );
///
/// final crossvault = Crossvault();
///
/// // Store a value (uses global config)
/// await crossvault.setValue('api_token', 'secret_value');
///
/// // Override global config for specific call
/// await crossvault.setValue(
///   'temp_token',
///   'temp_value',
///   options: IOSOptions(synchronizable: false),
/// );
///
/// // Retrieve a value
/// final value = await crossvault.getValue('api_token');
///
/// // Check if a key exists
/// final exists = await crossvault.existsKey('api_token');
///
/// // Delete a value
/// await crossvault.deleteValue('api_token');
/// ```
class Crossvault {
  /// Global configuration for all Crossvault operations.
  static CrossvaultConfig? _globalConfig;

  /// Initializes Crossvault with global configuration.
  ///
  /// This configuration will be used for all operations unless overridden
  /// in individual method calls.
  ///
  /// [config] Configuration with options for all platforms.
  ///
  /// Example:
  /// ```dart
  /// await Crossvault.init(
  ///   config: CrossvaultConfig(
  ///     ios: IOSOptions(
  ///       accessGroup: 'io.alexmelnyk.crossvault.shared',
  ///       synchronizable: true,
  ///     ),
  ///     android: AndroidOptions(
  ///       sharedPreferencesName: 'my_secure_prefs',
  ///       resetOnError: true,
  ///     ),
  ///   ),
  /// );
  /// ```
  static Future<void> init({CrossvaultConfig? config}) async {
    _globalConfig = config;
  }

  /// Resets the global configuration.
  static void reset() {
    _globalConfig = null;
  }

  /// Gets the appropriate platform options from config.
  CrossvaultOptions? _getPlatformOptions() {
    if (_globalConfig == null) {
      return null;
    }

    // Return platform-specific options from config
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _globalConfig!.ios;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return _globalConfig!.macos;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return _globalConfig!.android;
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return _globalConfig!.windows;
    }

    return null;
  }

  /// Merges global config with method-specific config.
  ///
  /// Method-specific config takes precedence over global config.
  CrossvaultOptions? _mergeConfigs(CrossvaultConfig? methodConfig) {
    // Get platform-specific options from global config
    final globalOptions = _getPlatformOptions();

    // Get platform-specific options from method config
    CrossvaultOptions? methodOptions;
    if (methodConfig != null) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        methodOptions = methodConfig.ios;
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        methodOptions = methodConfig.macos;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        methodOptions = methodConfig.android;
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        methodOptions = methodConfig.windows;
      }
    }

    // Merge: globalOptions < methodOptions
    if (globalOptions == null) {
      return methodOptions;
    } else if (methodOptions == null) {
      return globalOptions;
    }

    return globalOptions.merge(methodOptions);
  }

  /// Checks if a key exists in the secure storage.
  ///
  /// Returns `true` if the key exists, `false` otherwise.
  ///
  /// [key] The key to check for existence.
  /// [config] Platform-specific configuration.
  ///
  /// Example:
  /// ```dart
  /// final exists = await crossvault.existsKey('api_token');
  /// if (exists) {
  ///   print('Token exists');
  /// }
  /// ```
  ///
  /// Example with config override:
  /// ```dart
  /// final exists = await crossvault.existsKey(
  ///   'api_token',
  ///   config: CrossvaultConfig(
  ///     ios: IOSOptions(
  ///       accessGroup: 'io.alexmelnyk.crossvault.shared',
  ///     ),
  ///   ),
  /// );
  /// ```
  Future<bool> existsKey(String key, {CrossvaultConfig? config}) {
    return CrossvaultPlatform.instance.existsKey(
      key,
      options: _mergeConfigs(config),
    );
  }

  /// Retrieves a value from the secure storage.
  ///
  /// Returns the value associated with the key, or `null` if not found.
  ///
  /// [key] The key to retrieve the value for.
  /// [config] Platform-specific configuration.
  ///
  /// Example:
  /// ```dart
  /// final token = await crossvault.getValue('api_token');
  /// if (token != null) {
  ///   print('Token: $token');
  /// }
  /// ```
  Future<String?> getValue(String key, {CrossvaultConfig? config}) {
    return CrossvaultPlatform.instance.getValue(
      key,
      options: _mergeConfigs(config),
    );
  }

  /// Stores a value in the secure storage.
  ///
  /// [key] The key to store the value under.
  /// [value] The value to store.
  /// [config] Platform-specific configuration.
  ///
  /// Example:
  /// ```dart
  /// await crossvault.setValue('api_token', 'secret_value');
  /// ```
  ///
  /// Example with config override:
  /// ```dart
  /// await crossvault.setValue(
  ///   'api_token',
  ///   'secret_value',
  ///   config: CrossvaultConfig(
  ///     ios: IOSOptions(
  ///       accessGroup: 'io.alexmelnyk.crossvault.shared',
  ///       synchronizable: true,
  ///     ),
  ///     android: AndroidOptions(
  ///       sharedPreferencesName: 'my_secure_prefs',
  ///     ),
  ///   ),
  /// );
  /// ```
  Future<void> setValue(String key, String value, {CrossvaultConfig? config}) {
    return CrossvaultPlatform.instance.setValue(
      key,
      value,
      options: _mergeConfigs(config),
    );
  }

  /// Deletes a value from the secure storage.
  ///
  /// [key] The key to delete.
  /// [config] Platform-specific configuration.
  ///
  /// Example:
  /// ```dart
  /// await crossvault.deleteValue('api_token');
  /// ```
  Future<void> deleteValue(String key, {CrossvaultConfig? config}) {
    return CrossvaultPlatform.instance.deleteValue(
      key,
      options: _mergeConfigs(config),
    );
  }

  /// Deletes all values from the secure storage.
  ///
  /// [config] Platform-specific configuration.
  ///
  /// **Warning**: This will delete all stored values. Use with caution.
  ///
  /// Example:
  /// ```dart
  /// await crossvault.deleteAll();
  /// ```
  Future<void> deleteAll({CrossvaultConfig? config}) {
    return CrossvaultPlatform.instance.deleteAll(
      options: _mergeConfigs(config),
    );
  }
}
