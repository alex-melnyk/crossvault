import 'package:crossvault_platform_interface/src/options/crossvault_options.dart';
import 'package:crossvault_platform_interface/src/options/macos_accessibility.dart';

/// Options for macOS platform.
///
/// Provides configuration for macOS Keychain operations.
/// Similar to iOS but with macOS-specific considerations.
class MacOSOptions extends CrossvaultOptions {
  /// Creates macOS-specific options.
  ///
  /// [accessGroup] The Keychain access group identifier for sharing data
  /// between apps with the same Team ID.
  ///
  /// [synchronizable] Whether to sync this item with iCloud Keychain.
  /// Defaults to `false`.
  ///
  /// [accessibility] The accessibility level for the keychain item.
  /// See [MacOSAccessibility] for available options.
  const MacOSOptions({
    this.accessGroup,
    this.synchronizable = false,
    this.accessibility = MacOSAccessibility.afterFirstUnlock,
  });

  /// The Keychain access group identifier.
  final String? accessGroup;

  /// Whether to synchronize this item with iCloud Keychain.
  final bool synchronizable;

  /// The accessibility level for the keychain item.
  final MacOSAccessibility accessibility;

  @override
  MacOSOptions merge(CrossvaultOptions? other) {
    if (other == null || other is! MacOSOptions) {
      return this;
    }
    return MacOSOptions(
      accessGroup: other.accessGroup ?? accessGroup,
      synchronizable: other.synchronizable,
      accessibility: other.accessibility,
    );
  }

  @override
  String toString() {
    return 'MacOSOptions(accessGroup: $accessGroup, synchronizable: $synchronizable, accessibility: $accessibility)';
  }
}
