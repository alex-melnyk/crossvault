# macOS iCloud Keychain Sync Setup Guide

This guide explains how to configure iCloud Keychain synchronization for Crossvault in your macOS app.

## 📋 Table of Contents

- [What is iCloud Keychain Sync?](#what-is-icloud-keychain-sync)
- [Quick Setup](#quick-setup)
- [Detailed Configuration](#detailed-configuration)
- [Testing iCloud Sync](#testing-icloud-sync)
- [Troubleshooting](#troubleshooting)

## 🤔 What is iCloud Keychain Sync?

iCloud Keychain automatically syncs keychain items across all your Apple devices:

- ✅ **Real-time sync** - Changes sync immediately
- ✅ **End-to-end encrypted** - Apple cannot read your data
- ✅ **Cross-device** - Mac, iPhone, iPad with same Apple ID
- ✅ **Automatic** - No user action required
- ⚠️ **Requires Apple ID** - User must be signed in with iCloud

## 🚀 Quick Setup

### Step 1: Enable Keychain Sharing in Xcode

1. Open `macos/Runner.xcworkspace` in Xcode
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
  options: MacOSOptions(
    accessGroup: 'io.alexmelnyk.crossvault.shared',
    synchronizable: true,  // Enable iCloud sync
    accessibility: MacOSAccessibility.afterFirstUnlock,
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

**Entitlements file** (`macos/Runner/Runner.entitlements`):
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

#### 3. Code Configuration

```dart
// Enable iCloud sync
MacOSOptions(
  accessGroup: 'io.alexmelnyk.crossvault.shared',
  synchronizable: true,  // THIS enables iCloud sync
  accessibility: MacOSAccessibility.afterFirstUnlock,
)
```

### Synchronizable Flag

```dart
// Sync with iCloud
MacOSOptions(synchronizable: true)

// Don't sync (Mac-only)
MacOSOptions(synchronizable: false)
```

### Accessibility Levels

```dart
// Most secure - only when Mac is unlocked
MacOSAccessibility.whenUnlocked

// Balanced - after first unlock (recommended)
MacOSAccessibility.afterFirstUnlock

// Least secure - always accessible
MacOSAccessibility.always

// Mac-only variants (no iCloud sync)
MacOSAccessibility.whenUnlockedThisDeviceOnly
MacOSAccessibility.afterFirstUnlockThisDeviceOnly
MacOSAccessibility.alwaysThisDeviceOnly
```

### Mixed Mode Example

```dart
// Global config: sync by default
await Crossvault.init(
  options: MacOSOptions(
    accessGroup: 'io.alexmelnyk.crossvault.shared',
    synchronizable: true,
  ),
);

// This item will sync to iPhone/iPad
await crossvault.setValue('user_token', 'value');

// This item stays on Mac only
await crossvault.setValue(
  'mac_specific_key',
  'value',
  options: MacOSOptions(
    synchronizable: false,
    accessibility: MacOSAccessibility.afterFirstUnlockThisDeviceOnly,
  ),
);
```

## 🧪 Testing iCloud Sync

### Prerequisites

- ✅ Mac with macOS 10.9+
- ✅ iOS device (iPhone/iPad) or another Mac
- ✅ Same Apple ID on both devices
- ✅ iCloud enabled in System Preferences
- ✅ iCloud Keychain enabled

### Method 1: Mac + iPhone

1. **Mac:**
   ```dart
   await crossvault.setValue('mac_key', 'from_mac');
   ```

2. **Wait** ~5-10 seconds for sync

3. **iPhone:**
   ```dart
   final value = await crossvault.getValue('mac_key');
   print(value); // Should print: from_mac
   ```

### Method 2: Two Macs

1. **Mac 1:**
   ```dart
   await crossvault.setValue('test_key', 'test_value');
   ```

2. **Wait** for sync

3. **Mac 2:**
   ```dart
   final value = await crossvault.getValue('test_key');
   print(value); // Should print: test_value
   ```

### Method 3: Keychain Access App

1. Open **Keychain Access** app
2. Select **iCloud** keychain (left sidebar)
3. Search for your items
4. Verify they appear in iCloud keychain

### Viewing Synced Items

**Keychain Access:**
- Open Keychain Access app
- Select "iCloud" in left sidebar
- Search for your service name: `io.alexmelnyk.crossvault`
- Double-click item to view details

## 🐛 Troubleshooting

### Sync Not Working

**Problem**: Items not syncing between devices

**Solutions:**

1. **Check iCloud Keychain is enabled:**
   - System Preferences → Apple ID → iCloud → Keychain (checked)
   - On iOS: Settings → [Your Name] → iCloud → Keychain

2. **Verify same Apple ID:**
   - System Preferences → Apple ID
   - Must be same on all devices

3. **Check internet connection:**
   - iCloud sync requires internet
   - Try on Wi-Fi for faster sync

4. **Verify entitlements:**
   ```bash
   # Check entitlements
   codesign -d --entitlements - macos/build/macos/Build/Products/Debug/Runner.app
   ```

5. **Check synchronizable flag:**
   ```dart
   MacOSOptions(synchronizable: true)  // Must be true!
   ```

### "Keychain Sharing Not Enabled" Error

**Solution:**

1. Open Xcode
2. Select Runner target
3. Signing & Capabilities → + Capability → Keychain Sharing
4. Add access group
5. Clean and rebuild

### Items Not Visible in Keychain Access

**Problem**: Items saved but not visible in Keychain Access app

**Solution:**

1. **Check keychain:**
   - Make sure "iCloud" keychain is selected
   - Try "All Items" view

2. **Search correctly:**
   - Search by service name: `io.alexmelnyk.crossvault`
   - Or by account name (your key)

3. **Refresh view:**
   - Close and reopen Keychain Access
   - Or View → Refresh

### Slow Sync Between Mac and iOS

**Problem**: Sync takes too long

**Solutions:**

1. **Check network:**
   - Use Wi-Fi on both devices
   - Check internet speed

2. **Force sync:**
   - Lock and unlock Mac
   - On iOS: Lock and unlock device

3. **Restart devices:**
   - Sometimes helps clear sync queue

4. **Check iCloud status:**
   - System Preferences → Apple ID → iCloud
   - Verify iCloud is working

## 🔒 Security Considerations

### What's Synced?

- ✅ **Encrypted data** - Your keychain items
- ✅ **Metadata** - Item attributes (encrypted)
- ✅ **Access control** - Accessibility settings

### What's NOT Synced?

- ❌ **Items with "ThisDeviceOnly" accessibility**
- ❌ **Items with `synchronizable: false`**
- ❌ **Mac-specific secure items**

### Encryption

- **End-to-end encrypted** - Apple cannot read your data
- **Device keys** - Each device has unique encryption keys
- **iCloud keys** - Separate keys for iCloud storage
- **Zero-knowledge** - Apple doesn't have decryption keys

### Best Practices

1. **Use appropriate accessibility:**
   ```dart
   // For sensitive data
   MacOSAccessibility.whenUnlocked
   
   // For general data (recommended)
   MacOSAccessibility.afterFirstUnlock
   ```

2. **Don't sync device-specific data:**
   ```dart
   // Mac serial number should not sync
   MacOSOptions(
     synchronizable: false,
     accessibility: MacOSAccessibility.afterFirstUnlockThisDeviceOnly,
   )
   ```

3. **Test on multiple devices:**
   - Verify sync works correctly
   - Test Mac → iPhone sync
   - Test Mac → Mac sync

## 📱 Device Requirements

### Minimum Requirements

- ✅ macOS 10.9+ (Mavericks)
- ✅ Apple ID signed in
- ✅ iCloud Keychain enabled
- ✅ Internet connection

### Supported Devices for Sync

- ✅ Mac (macOS 10.9+)
- ✅ iPhone (iOS 7+)
- ✅ iPad (iOS 7+)
- ✅ Apple Watch (watchOS 2+)

### Checking Mac Support

```bash
# Check macOS version
sw_vers

# Check iCloud status
defaults read MobileMeAccounts Accounts
```

## 🔄 Sync Behavior

### When Does Sync Happen?

- **Immediately** after item is saved
- **Background** sync every few seconds
- **On wake** Mac sync check
- **On network change** sync retry

### Sync Direction

- **Bidirectional** - Changes sync both ways
- **Mac → iOS** - Works
- **iOS → Mac** - Works
- **Mac → Mac** - Works

### Conflict Resolution

- **Last write wins** - Most recent change takes precedence
- **Automatic** - No manual resolution needed
- **Timestamp-based** - Uses device time

## 💡 Tips

### Tip 1: View Synced Items

Use Keychain Access to debug:

1. Open Keychain Access
2. Select "iCloud" keychain
3. View all synced items
4. Check sync status

### Tip 2: Test Sync in Development

```dart
// Add test button
ElevatedButton(
  onPressed: () async {
    final timestamp = DateTime.now().toString();
    await crossvault.setValue('sync_test', timestamp);
    print('Saved: $timestamp');
  },
  child: Text('Test Sync'),
);
```

### Tip 3: Monitor Sync

```dart
try {
  await crossvault.setValue('key', 'value');
  print('✅ Saved to keychain (syncing to iCloud)');
} catch (e) {
  print('❌ Error: $e');
}
```

### Tip 4: Handle Offline Mode

```dart
// Items are saved locally even offline
// Will sync when connection restored
await crossvault.setValue('key', 'value');
```

## ❓ FAQ

### Q: Is iCloud Keychain sync enabled by default?

**A:** No, you must enable Keychain Sharing and iCloud capabilities in Xcode, and set `synchronizable: true` in code.

### Q: Can users disable iCloud Keychain?

**A:** Yes, in System Preferences → Apple ID → iCloud → Keychain. Your app should handle this gracefully.

### Q: How fast is sync?

**A:** Usually 5-10 seconds. Can be slower on poor network.

### Q: Does sync work offline?

**A:** No, but items are saved locally and will sync when connection is restored.

### Q: Can I sync between macOS and Android?

**A:** No, iCloud Keychain is Apple-only.

### Q: What happens if I sign out of iCloud?

**A:** Synced items remain on Mac but won't sync. Items are deleted from iCloud after 30 days.

### Q: Can I see sync status?

**A:** Use Keychain Access app to view synced items in iCloud keychain.

### Q: Does sync use bandwidth?

**A:** Yes, but minimal (few KB per sync).

---

## ✅ Checklist

Before deploying your app, verify:

- [ ] Keychain Sharing capability enabled in Xcode
- [ ] iCloud capability enabled in Xcode
- [ ] Access group configured in entitlements
- [ ] `synchronizable: true` in code (if you want sync)
- [ ] Tested sync between Mac and iOS device
- [ ] Tested with poor network conditions
- [ ] Documented iCloud requirement for users
- [ ] Error handling implemented

---

## 📚 Additional Resources

- [Apple: iCloud Keychain](https://support.apple.com/en-us/HT204085)
- [Apple: Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [Apple: Sharing Keychain Items](https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps)

---

**Need help?** Check the [Crossvault macOS README](../../../crossvault_macos/README.md) for more details.
