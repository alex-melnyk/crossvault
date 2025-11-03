import 'package:crossvault_platform_interface/src/options/crossvault_options.dart';

/// Options for Android platform.
///
/// Provides configuration for Android EncryptedSharedPreferences.
class AndroidOptions extends CrossvaultOptions {
  /// Creates Android-specific options.
  ///
  /// [sharedPreferencesName] The name of the SharedPreferences file.
  /// Defaults to `'crossvault_secure_storage'`.
  ///
  /// [resetOnError] Whether to reset the encrypted storage on error.
  /// Defaults to `true`.
  const AndroidOptions({
    this.sharedPreferencesName = 'crossvault_secure_storage',
    this.resetOnError = true,
  });

  /// The name of the SharedPreferences file.
  final String sharedPreferencesName;

  /// Whether to reset the encrypted storage on error.
  ///
  /// When `true`, if decryption fails (e.g., after device security changes),
  /// the storage will be cleared and re-initialized.
  final bool resetOnError;

  @override
  AndroidOptions merge(CrossvaultOptions? other) {
    if (other == null || other is! AndroidOptions) {
      return this;
    }
    return AndroidOptions(
      sharedPreferencesName: other.sharedPreferencesName,
      resetOnError: other.resetOnError,
    );
  }

  @override
  String toString() {
    return 'AndroidOptions(sharedPreferencesName: $sharedPreferencesName, resetOnError: $resetOnError)';
  }
}
