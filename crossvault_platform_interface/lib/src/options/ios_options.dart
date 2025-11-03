import 'package:crossvault_platform_interface/src/options/crossvault_options.dart';
import 'package:crossvault_platform_interface/src/options/ios_accessibility.dart';

/// Options for iOS platform.
///
/// Provides configuration for iOS Keychain operations.
class IOSOptions extends CrossvaultOptions {
  /// Creates iOS-specific options.
  ///
  /// [accessGroup] The Keychain access group identifier for sharing data
  /// between apps with the same Team ID. Format: `$(AppIdentifierPrefix)com.yourcompany.shared`
  ///
  /// [synchronizable] Whether to sync this item with iCloud Keychain.
  /// Defaults to `false`.
  ///
  /// [accessibility] The accessibility level for the keychain item.
  /// See [IOSAccessibility] for available options.
  const IOSOptions({
    this.accessGroup,
    this.synchronizable = false,
    this.accessibility = IOSAccessibility.afterFirstUnlock,
  });

  /// The Keychain access group identifier.
  ///
  /// This allows sharing keychain items between apps with the same Team ID.
  /// Must be configured in your app's entitlements.
  ///
  /// Example: `io.alexmelnyk.crossvault.shared`
  final String? accessGroup;

  /// Whether to synchronize this item with iCloud Keychain.
  ///
  /// When `true`, the item will be synced across all devices signed in
  /// with the same iCloud account.
  final bool synchronizable;

  /// The accessibility level for the keychain item.
  ///
  /// Determines when the keychain item can be accessed.
  final IOSAccessibility accessibility;

  @override
  IOSOptions merge(CrossvaultOptions? other) {
    if (other == null || other is! IOSOptions) {
      return this;
    }
    return IOSOptions(
      accessGroup: other.accessGroup ?? accessGroup,
      synchronizable: other.synchronizable,
      accessibility: other.accessibility,
    );
  }

  @override
  String toString() {
    return 'IOSOptions(accessGroup: $accessGroup, synchronizable: $synchronizable, accessibility: $accessibility)';
  }
}
