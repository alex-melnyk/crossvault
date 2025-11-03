# iOS/macOS iCloud Keychain Sync - Quick Setup

Quick reference for setting up iCloud Keychain synchronization in your iOS/macOS app.

## ⚡ 3-Step Setup

### 1. Enable Keychain Sharing in Xcode

1. Open `ios/Runner.xcworkspace` (or `macos/Runner.xcworkspace`)
2. Select **Runner** target
3. **Signing & Capabilities** → **+ Capability** → **Keychain Sharing**
4. Add access group: `$(AppIdentifierPrefix)io.alexmelnyk.crossvault.shared`

### 2. Enable iCloud in Xcode

1. **Signing & Capabilities** → **+ Capability** → **iCloud**
2. Check **iCloud Keychain**

### 3. Configure in Code

```dart
await Crossvault.init(
  options: IOSOptions(  // or MacOSOptions for macOS
    accessGroup: 'io.alexmelnyk.crossvault.shared',
    synchronizable: true,  // Enable iCloud sync
    accessibility: IOSAccessibility.afterFirstUnlock,
  ),
);
```

## ✅ Done!

Your keychain items will now sync across all devices with the same Apple ID.

## 🧪 Test It

### Two Devices

**Device 1:**
```dart
await crossvault.setValue('test_key', 'test_value');
```

**Wait 5-10 seconds**

**Device 2:**
```dart
final value = await crossvault.getValue('test_key');
print(value); // Should print: test_value
```

### Keychain Access (Mac)

1. Open **Keychain Access** app
2. Select **iCloud** keychain
3. Search for `io.alexmelnyk.crossvault`
4. Verify items appear

## 📚 Full Documentation

- [iOS Setup Guide](crossvault/example/ios/SETUP_ICLOUD_SYNC.md)
- [macOS Setup Guide](crossvault/example/macos/SETUP_ICLOUD_SYNC.md)
- [iOS Plugin README](crossvault_ios/README.md)
- [macOS Plugin README](crossvault_macos/README.md)

## 🔧 Mixed Mode (Some Sync, Some Don't)

```dart
// Global: sync by default
await Crossvault.init(
  options: IOSOptions(
    accessGroup: 'io.alexmelnyk.crossvault.shared',
    synchronizable: true,
  ),
);

// This syncs to all devices
await crossvault.setValue('user_token', 'value');

// This stays on device only
await crossvault.setValue(
  'device_id',
  'value',
  options: IOSOptions(
    synchronizable: false,
    accessibility: IOSAccessibility.afterFirstUnlockThisDeviceOnly,
  ),
);
```

## ⚠️ Important

- **Real-time sync** - Changes sync within 5-10 seconds
- **Requires Apple ID** - User must be signed in with iCloud
- **Requires internet** - Sync needs network connection
- **End-to-end encrypted** - Apple cannot read your data
- **Cross-device** - Works on iPhone, iPad, Mac, Apple Watch

## 🐛 Troubleshooting

### Sync not working?

1. Check iCloud Keychain is enabled:
   - iOS: Settings → [Name] → iCloud → Keychain
   - Mac: System Preferences → Apple ID → iCloud → Keychain

2. Verify same Apple ID on all devices

3. Check internet connection

4. Verify `synchronizable: true` in code

5. Check entitlements are configured correctly

### Items not visible?

- On Mac: Open Keychain Access → Select "iCloud" keychain
- Search for: `io.alexmelnyk.crossvault`

## 📊 Comparison: iOS/macOS vs Android

| Feature | iOS/macOS | Android |
|---------|-----------|---------|
| **Sync Type** | Real-time | Backup (~24h) |
| **Sync Speed** | 5-10 seconds | Up to 24 hours |
| **Cloud Service** | iCloud | Google Drive |
| **Requires** | Apple ID | Google account |
| **Cross-platform** | Apple devices only | Android devices only |
| **Encryption** | End-to-end | End-to-end |

## 💡 Tips

### Tip 1: Test Early

Always test sync during development on real devices.

### Tip 2: Handle Offline

Items save locally even offline and sync when connection restored.

### Tip 3: Use Appropriate Accessibility

```dart
// Most secure
IOSAccessibility.whenUnlocked

// Balanced (recommended)
IOSAccessibility.afterFirstUnlock

// Device-only (no sync)
IOSAccessibility.afterFirstUnlockThisDeviceOnly
```

### Tip 4: Don't Sync Device-Specific Data

```dart
// Device ID should not sync
IOSOptions(
  synchronizable: false,
  accessibility: IOSAccessibility.afterFirstUnlockThisDeviceOnly,
)
```
