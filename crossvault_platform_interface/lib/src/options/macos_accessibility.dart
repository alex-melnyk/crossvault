/// macOS Keychain accessibility levels.
///
/// Determines when a keychain item can be accessed.
enum MacOSAccessibility {
  /// The item can only be accessed when the Mac is unlocked.
  ///
  /// This is the most secure option. The item cannot be accessed
  /// when the Mac is locked.
  whenUnlocked,

  /// The item can be accessed after the first unlock.
  ///
  /// This is the default and recommended option. The item can be accessed
  /// after the Mac has been unlocked once after boot.
  afterFirstUnlock,

  /// The item can always be accessed.
  ///
  /// This is the least secure option. The item can be accessed even
  /// when the Mac is locked. Not recommended for sensitive data.
  always,

  /// Same as [whenUnlocked], but the item is not synced with iCloud.
  whenUnlockedThisDeviceOnly,

  /// Same as [afterFirstUnlock], but the item is not synced with iCloud.
  afterFirstUnlockThisDeviceOnly,

  /// Same as [always], but the item is not synced with iCloud.
  alwaysThisDeviceOnly,
}
