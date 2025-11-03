import 'package:crossvault_platform_interface/crossvault_platform_interface.dart';
import 'package:flutter/foundation.dart';

// Re-export options for convenience
export 'package:crossvault_platform_interface/crossvault_platform_interface.dart'
    show
        CrossvaultOptions,
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
  @visibleForTesting
  static CrossvaultOptions? _globalOptions;

  /// Initializes Crossvault with global configuration.
  ///
  /// This configuration will be used for all operations unless overridden
  /// in individual method calls.
  ///
  /// [options] Platform-specific options (IOSOptions, MacOSOptions, AndroidOptions, WindowsOptions).
  ///
  /// Example:
  /// ```dart
  /// // iOS with access group
  /// await Crossvault.init(
  ///   options: IOSOptions(
  ///     accessGroup: 'io.alexmelnyk.crossvault.shared',
  ///     synchronizable: true,
  ///     accessibility: IOSAccessibility.whenUnlocked,
  ///   ),
  /// );
  ///
  /// // Android with custom preferences name
  /// await Crossvault.init(
  ///   options: AndroidOptions(
  ///     sharedPreferencesName: 'my_secure_prefs',
  ///     resetOnError: true,
  ///   ),
  /// );
  /// ```
  static Future<void> init({CrossvaultOptions? options}) async {
    _globalOptions = options;
  }

  /// Resets the global configuration.
  static void reset() {
    _globalOptions = null;
  }

  /// Merges global options with method-specific options.
  ///
  /// Method-specific options take precedence over global options.
  @visibleForTesting
  CrossvaultOptions? _mergeOptions(CrossvaultOptions? methodOptions) {
    if (_globalOptions == null) {
      return methodOptions;
    } else if (methodOptions == null) {
      return _globalOptions;
    }

    return _globalOptions!.merge(methodOptions);
  }
  /// Returns the platform version.
  ///
  /// This is a demo method and will be removed in future versions.
  Future<String?> getPlatformVersion() {
    return CrossvaultPlatform.instance.getPlatformVersion();
  }

  /// Checks if a key exists in the secure storage.
  ///
  /// Returns `true` if the key exists, `false` otherwise.
  ///
  /// [key] The key to check for existence.
  /// [options] Platform-specific options (IOSOptions, MacOSOptions, AndroidOptions, WindowsOptions).
  ///
  /// Example:
  /// ```dart
  /// final exists = await crossvault.existsKey('api_token');
  /// if (exists) {
  ///   print('Token exists');
  /// }
  /// ```
  ///
  /// Example with iOS options:
  /// ```dart
  /// final exists = await crossvault.existsKey(
  ///   'api_token',
  ///   options: IOSOptions(
  ///     accessGroup: 'io.alexmelnyk.crossvault.shared',
  ///   ),
  /// );
  /// ```
  Future<bool> existsKey(String key, {CrossvaultOptions? options}) {
    return CrossvaultPlatform.instance.existsKey(
      key,
      options: _mergeOptions(options),
    );
  }

  /// Retrieves a value from the secure storage.
  ///
  /// Returns the value associated with the key, or `null` if not found.
  ///
  /// [key] The key to retrieve the value for.
  /// [options] Platform-specific options (IOSOptions, MacOSOptions, AndroidOptions, WindowsOptions).
  ///
  /// Example:
  /// ```dart
  /// final token = await crossvault.getValue('api_token');
  /// if (token != null) {
  ///   print('Token: $token');
  /// }
  /// ```
  Future<String?> getValue(String key, {CrossvaultOptions? options}) {
    return CrossvaultPlatform.instance.getValue(
      key,
      options: _mergeOptions(options),
    );
  }

  /// Stores a value in the secure storage.
  ///
  /// [key] The key to store the value under.
  /// [value] The value to store.
  /// [options] Platform-specific options (IOSOptions, MacOSOptions, AndroidOptions, WindowsOptions).
  ///
  /// Example:
  /// ```dart
  /// await crossvault.setValue('api_token', 'secret_value');
  /// ```
  ///
  /// Example with iOS options (access group + iCloud sync):
  /// ```dart
  /// await crossvault.setValue(
  ///   'api_token',
  ///   'secret_value',
  ///   options: IOSOptions(
  ///     accessGroup: 'io.alexmelnyk.crossvault.shared',
  ///     synchronizable: true,
  ///     accessibility: IOSAccessibility.whenUnlocked,
  ///   ),
  /// );
  /// ```
  ///
  /// Example with Android options:
  /// ```dart
  /// await crossvault.setValue(
  ///   'api_token',
  ///   'secret_value',
  ///   options: AndroidOptions(
  ///     sharedPreferencesName: 'my_secure_prefs',
  ///   ),
  /// );
  /// ```
  Future<void> setValue(String key, String value, {CrossvaultOptions? options}) {
    return CrossvaultPlatform.instance.setValue(
      key,
      value,
      options: _mergeOptions(options),
    );
  }

  /// Deletes a value from the secure storage.
  ///
  /// [key] The key to delete.
  /// [options] Platform-specific options (IOSOptions, MacOSOptions, AndroidOptions, WindowsOptions).
  ///
  /// Example:
  /// ```dart
  /// await crossvault.deleteValue('api_token');
  /// ```
  Future<void> deleteValue(String key, {CrossvaultOptions? options}) {
    return CrossvaultPlatform.instance.deleteValue(
      key,
      options: _mergeOptions(options),
    );
  }

  /// Deletes all values from the secure storage.
  ///
  /// [options] Platform-specific options (IOSOptions, MacOSOptions, AndroidOptions, WindowsOptions).
  ///
  /// **Warning**: This will delete all stored values. Use with caution.
  ///
  /// Example:
  /// ```dart
  /// await crossvault.deleteAll();
  /// ```
  Future<void> deleteAll({CrossvaultOptions? options}) {
    return CrossvaultPlatform.instance.deleteAll(
      options: _mergeOptions(options),
    );
  }
}
