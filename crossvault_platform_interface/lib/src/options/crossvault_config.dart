import 'package:crossvault_platform_interface/src/options/android_options.dart';
import 'package:crossvault_platform_interface/src/options/ios_options.dart';
import 'package:crossvault_platform_interface/src/options/macos_options.dart';
import 'package:crossvault_platform_interface/src/options/windows_options.dart';

/// Configuration for Crossvault with platform-specific options.
///
/// This class allows you to configure options for all platforms at once,
/// making it easier to set up cross-platform secure storage.
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
///       sharedPreferencesName: 'my_secure_storage',
///       resetOnError: true,
///     ),
///   ),
/// );
/// ```
class CrossvaultConfig {
  /// Creates a configuration with platform-specific options.
  const CrossvaultConfig({
    this.ios,
    this.macos,
    this.android,
    this.windows,
  });

  /// Options for iOS platform.
  ///
  /// Used when running on iOS devices.
  final IOSOptions? ios;

  /// Options for macOS platform.
  ///
  /// Used when running on macOS.
  final MacOSOptions? macos;

  /// Options for Android platform.
  ///
  /// Used when running on Android devices.
  final AndroidOptions? android;

  /// Options for Windows platform.
  ///
  /// Used when running on Windows.
  final WindowsOptions? windows;

  /// Merges this config with another config.
  ///
  /// The [other] config will override values in this config.
  /// Returns a new config instance with merged values.
  CrossvaultConfig merge(CrossvaultConfig? other) {
    if (other == null) {
      return this;
    }

    return CrossvaultConfig(
      ios: other.ios ?? ios,
      macos: other.macos ?? macos,
      android: other.android ?? android,
      windows: other.windows ?? windows,
    );
  }

  @override
  String toString() {
    return 'CrossvaultConfig(ios: $ios, macos: $macos, android: $android, windows: $windows)';
  }
}
