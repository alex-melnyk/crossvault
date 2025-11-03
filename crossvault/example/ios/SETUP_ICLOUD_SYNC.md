# iOS iCloud Keychain Sync Setup Guide

This guide explains how to configure iCloud Keychain synchronization for Crossvault in your iOS app.

## 📋 Table of Contents

- [What is iCloud Keychain Sync?](#what-is-icloud-keychain-sync)
- [Quick Setup](#quick-setup)
- [Detailed Configuration](#detailed-configuration)
- [Testing iCloud Sync](#testing-icloud-sync)
- [Troubleshooting](#troubleshooting)

## 🤔 What is iCloud Keychain Sync?

iCloud Keychain is an Apple feature that automatically syncs keychain items across all your devices:

- ✅ **Real-time sync** - Changes sync immediately
- ✅ **End-to-end encrypted** - Apple cannot read your data
- ✅ **Automatic** - No user action required
- ✅ **Cross-device** - iPhone, iPad, Mac with same Apple ID
- ⚠️ **Requires Apple ID** - User must be signed in with iCloud

## 🚀 Quick Setup

### Step 1: Enable Keychain Sharing in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **Keychain Sharing**
6. Add your access group: `$(AppIdentifierPrefix)io.alexmelnyk.crossvault.shared`

### Step 2: Enable iCloud in Xcode

1. In **Signing & Capabilities** tab
2. Click **+ Capability**
3. Add **iCloud**
4. Check **iCloud Keychain**

### Step 3: Configure in Code

```dart
await Crossvault.init(
  options: IOSOptions(
    accessGroup: 'io.alexmelnyk.crossvault.shared',
    synchronizable: true,  // Enable iCloud sync
    accessibility: IOSAccessibility.afterFirstUnlock,
  ),
);
```

### Step 4: Done! 🎉

Your keychain items will now sync across all devices signed in with the same Apple ID.

## 📖 Detailed Configuration

### Understanding the Configuration

#### 1. Keychain Sharing

Required to share keychain items between apps or enable iCloud sync.

**Xcode Setup:**
- Target → Signing & Capabilities → + Capability → Keychain Sharing
- Add access group: `$(AppIdentifierPrefix)your.bundle.id.shared`

**Entitlements file** (`ios/Runner/Runner.entitlements`):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)io.alexmelnyk.crossvault.shared</string>
    </array>
</dict>
</plist>
```

#### 2. iCloud Capability

Required for iCloud Keychain sync.

**Xcode Setup:**
- Target → Signing & Capabilities → + Capability → iCloud
- Check **iCloud Keychain**

**Entitlements file** (updated):
```xml
<dict>
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)io.alexmelnyk.crossvault.shared</string>
    </array>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array/>
    <key>com.apple.developer.ubiquity-kvstore-identifier</key>
    <string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
</dict>
```

#### 3. Code Configuration

```dart
// Enable iCloud sync
IOSOptions(
  accessGroup: 'io.alexmelnyk.crossvault.shared',
  synchronizable: true,  // THIS enables iCloud sync
  accessibility: IOSAccessibility.afterFirstUnlock,
)
```

### Synchronizable Flag

The `synchronizable` flag controls iCloud sync:

```dart
// Sync with iCloud
IOSOptions(synchronizable: true)

// Don't sync (device-only)
IOSOptions(synchronizable: false)
```

### Accessibility Levels

Choose appropriate accessibility for your use case:

```dart
// Most secure - only when device is unlocked
IOSAccessibility.whenUnlocked

// Balanced - after first unlock (recommended)
IOSAccessibility.afterFirstUnlock

// Least secure - always accessible
IOSAccessibility.always

// Device-only variants (no iCloud sync)
IOSAccessibility.whenUnlockedThisDeviceOnly
IOSAccessibility.afterFirstUnlockThisDeviceOnly
IOSAccessibility.alwaysThisDeviceOnly
```

### Mixed Mode: Some Items Sync, Some Don't

```dart
// Global config: sync by default
await Crossvault.init(
  options: IOSOptions(
    accessGroup: 'io.alexmelnyk.crossvault.shared',
    synchronizable: true,
  ),
);

// This item will sync
await crossvault.setValue('user_token', 'value');

// This item won't sync (device-only)
await crossvault.setValue(
  'device_id',
  'value',
  options: IOSOptions(
    synchronizable: false,
    accessibility: IOSAccessibility.afterFirstUnlockThisDeviceOnly,
  ),
);
```

## 🧪 Testing iCloud Sync

### Prerequisites

- ✅ Two iOS devices (or iOS device + Mac)
- ✅ Same Apple ID on both devices
- ✅ iCloud enabled in Settings
- ✅ iCloud Keychain enabled

### Method 1: Two iOS Devices

1. **Device 1:**
   ```dart
   await crossvault.setValue('test_key', 'test_value');
   ```

2. **Wait** ~5-10 seconds for sync

3. **Device 2:**
   ```dart
   final value = await crossvault.getValue('test_key');
   print(value); // Should print: test_value
   ```

### Method 2: iOS Device + Mac

1. **iPhone:**
   ```dart
   await crossvault.setValue('phone_key', 'from_iphone');
   ```

2. **Wait** for sync

3. **Mac:**
   ```dart
   final value = await crossvault.getValue('phone_key');
   print(value); // Should print: from_iphone
   ```

### Method 3: Check Keychain Access (Mac)

1. Open **Keychain Access** app on Mac
2. Select **iCloud** keychain
3. Search for your items
4. Verify they appear in iCloud keychain

### Sync Timing

- **Immediate**: Changes usually sync within 5-10 seconds
- **Network required**: Devices must be connected to internet
- **Background sync**: Happens automatically

## 🐛 Troubleshooting

### Sync Not Working

**Problem**: Items not syncing between devices

**Solutions:**

1. **Check iCloud Keychain is enabled:**
   - Settings → [Your Name] → iCloud → Keychain → ON
   - On Mac: System Preferences → Apple ID → iCloud → Keychain

2. **Verify same Apple ID:**
   - Both devices must use same Apple ID
   - Check: Settings → [Your Name]

3. **Check internet connection:**
   - iCloud sync requires internet
   - Try on Wi-Fi for faster sync

4. **Verify entitlements:**
   ```bash
   # Check entitlements
   codesign -d --entitlements - ios/build/Runner.app
   ```

5. **Check synchronizable flag:**
   ```dart
   IOSOptions(synchronizable: true)  // Must be true!
   ```

### "Keychain Sharing Not Enabled" Error

**Problem**: App crashes or throws error about keychain sharing

**Solution:**

1. Open Xcode
2. Select Runner target
3. Signing & Capabilities → + Capability → Keychain Sharing
4. Add access group
5. Clean and rebuild

### Items Sync But Can't Access

**Problem**: Items appear in Keychain Access but app can't read them

**Solution:**

1. **Check access group matches:**
   ```dart
   // In code
   IOSOptions(accessGroup: 'io.alexmelnyk.crossvault.shared')
   
   // In entitlements
   $(AppIdentifierPrefix)io.alexmelnyk.crossvault.shared
   ```

2. **Verify Team ID:**
   - All devices must use same Team ID
   - Check in Xcode: Target → Signing & Capabilities

### Slow Sync

**Problem**: Sync takes too long

**Solutions:**

1. **Check network:**
   - Use Wi-Fi instead of cellular
   - Check internet speed

2. **Force sync:**
   - Lock and unlock device
   - Toggle Airplane mode on/off

3. **Restart devices:**
   - Sometimes helps clear sync queue

### "Item Not Found" After Sync

**Problem**: Item exists on Device 1 but not found on Device 2

**Solutions:**

1. **Wait longer:**
   - Initial sync can take up to 1 minute
   - Subsequent syncs are faster

2. **Check accessibility:**
   ```dart
   // Use appropriate accessibility
   IOSAccessibility.afterFirstUnlock  // Recommended
   ```

3. **Verify both devices online:**
   - Both must be connected to internet
   - Check iCloud status

## 🔒 Security Considerations

### What's Synced?

- ✅ **Encrypted data** - Your keychain items
- ✅ **Metadata** - Item attributes (encrypted)
- ✅ **Access control** - Accessibility settings

### What's NOT Synced?

- ❌ **Items with "ThisDeviceOnly" accessibility**
- ❌ **Items with `synchronizable: false`**
- ❌ **Biometric-protected items** (device-specific)

### Encryption

- **End-to-end encrypted** - Apple cannot read your data
- **Device keys** - Each device has unique encryption keys
- **iCloud keys** - Separate keys for iCloud storage
- **Zero-knowledge** - Apple doesn't have decryption keys

### Best Practices

1. **Use appropriate accessibility:**
   ```dart
   // For sensitive data
   IOSAccessibility.whenUnlocked
   
   // For general data
   IOSAccessibility.afterFirstUnlock
   ```

2. **Don't sync device-specific data:**
   ```dart
   // Device ID should not sync
   IOSOptions(
     synchronizable: false,
     accessibility: IOSAccessibility.afterFirstUnlockThisDeviceOnly,
   )
   ```

3. **Handle sync conflicts:**
   ```dart
   // Last write wins
   // No conflict resolution needed
   ```

4. **Test on multiple devices:**
   - Verify sync works correctly
   - Test with poor network conditions

## 📱 Device Requirements

### Minimum Requirements

- ✅ iOS 7.0+ for basic iCloud Keychain
- ✅ iOS 11.0+ for modern features
- ✅ Apple ID signed in
- ✅ iCloud Keychain enabled
- ✅ Internet connection

### Checking Device Support

```swift
// Check if iCloud Keychain is available
if let _ = SecItemCopyMatching(...) {
    // iCloud Keychain available
}
```

### Supported Devices

- ✅ iPhone (iOS 7+)
- ✅ iPad (iOS 7+)
- ✅ Mac (macOS 10.9+)
- ✅ Apple Watch (watchOS 2+)
- ❌ Apple TV (limited support)

## 🔄 Sync Behavior

### When Does Sync Happen?

- **Immediately** after item is saved
- **Background** sync every few seconds
- **On unlock** device sync check
- **On network change** sync retry

### Sync Priority

1. **High priority**: User-initiated changes
2. **Normal priority**: Background updates
3. **Low priority**: Bulk operations

### Conflict Resolution

- **Last write wins** - Most recent change takes precedence
- **No manual resolution** - Automatic
- **Timestamp-based** - Uses device time

## 💡 Tips

### Tip 1: Test Sync Early

Always test iCloud sync during development:

```dart
// Add test button in debug mode
if (kDebugMode) {
  ElevatedButton(
    onPressed: () async {
      await crossvault.setValue('sync_test', DateTime.now().toString());
    },
    child: Text('Test Sync'),
  );
}
```

### Tip 2: Monitor Sync Status

Log sync operations:

```dart
try {
  await crossvault.setValue('key', 'value');
  print('✅ Saved (will sync to iCloud)');
} catch (e) {
  print('❌ Error: $e');
}
```

### Tip 3: Handle Offline Mode

```dart
// Items are saved locally even offline
// Will sync when connection restored
await crossvault.setValue('key', 'value');
// Saved locally, will sync later
```

### Tip 4: Use Access Groups Wisely

```dart
// Same access group for all apps that need to share
IOSOptions(accessGroup: 'com.yourcompany.shared')

// Different access groups for isolation
IOSOptions(accessGroup: 'com.yourcompany.app1')
IOSOptions(accessGroup: 'com.yourcompany.app2')
```

## ❓ FAQ

### Q: Is iCloud Keychain sync enabled by default?

**A:** No, you must:
1. Enable Keychain Sharing capability in Xcode
2. Enable iCloud capability
3. Set `synchronizable: true` in code

### Q: Can users disable iCloud Keychain?

**A:** Yes, in Settings → [Name] → iCloud → Keychain. Your app should handle this gracefully.

### Q: How fast is sync?

**A:** Usually 5-10 seconds. Can be slower on poor network or first sync.

### Q: Does sync work offline?

**A:** No, but items are saved locally and will sync when connection is restored.

### Q: What's the size limit?

**A:** No specific limit for keychain items, but keep items small (< 1KB recommended).

### Q: Can I force immediate sync?

**A:** No, sync is automatic. But it usually happens within seconds.

### Q: Does sync use cellular data?

**A:** Yes, but data usage is minimal (few KB per sync).

### Q: Can I sync between iOS and Android?

**A:** No, iCloud Keychain is Apple-only. For cross-platform sync, use a custom backend.

### Q: What happens if I sign out of iCloud?

**A:** Synced items remain on device but won't sync. Items are deleted from iCloud after 30 days.

### Q: Can I see what's syncing?

**A:** On Mac, use Keychain Access app → iCloud keychain to view synced items.

---

## ✅ Checklist

Before deploying your app, verify:

- [ ] Keychain Sharing capability enabled in Xcode
- [ ] iCloud capability enabled in Xcode
- [ ] Access group configured in entitlements
- [ ] `synchronizable: true` in code (if you want sync)
- [ ] Tested sync between two devices
- [ ] Tested with poor network conditions
- [ ] Documented iCloud requirement for users
- [ ] Error handling implemented

---

## 📚 Additional Resources

- [Apple: iCloud Keychain](https://support.apple.com/en-us/HT204085)
- [Apple: Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [Apple: Sharing Access to Keychain Items](https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps)

---

**Need help?** Check the [Crossvault iOS README](../../../crossvault_ios/README.md) for more details.
