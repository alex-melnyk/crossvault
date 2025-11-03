# Crossvault Example

A comprehensive demo application showcasing all features of the Crossvault plugin.

## Features

- ✅ **Interactive UI** - Modern Material 3 design
- ✅ **Storage Mode Toggle** - Switch between Private and Shared modes
- ✅ **All Operations** - Set, Get, Exists, Delete, Delete All
- ✅ **Error Handling** - Visual feedback for all operations
- ✅ **Quick Examples** - Pre-filled examples for quick testing
- ✅ **Platform Detection** - Shows current platform and version
- ✅ **Modern macOS Window** - Frameless window with traffic light buttons

## Running the Example

### iOS
```bash
flutter run -d ios
```

**Note:** For iCloud Keychain sync between devices, see [iOS iCloud Sync Setup Guide](ios/SETUP_ICLOUD_SYNC.md).

### macOS (Modern Frameless Window)
```bash
flutter run -d macos
```

The macOS app features:
- 🎨 Transparent title bar
- 🚦 Traffic light buttons (close, minimize, maximize)
- 📏 Minimum window size: 800x600
- 🎯 Centered on launch
- 🖱️ Draggable by background

**Note:** For iCloud Keychain sync between devices, see [macOS iCloud Sync Setup Guide](macos/SETUP_ICLOUD_SYNC.md).

### Android
```bash
flutter run -d android
```

**Note:** Auto Backup is pre-configured in this example app. See [Android Auto Backup Setup Guide](android/SETUP_AUTO_BACKUP.md) for details on how to configure it in your own app.

### Windows
```bash
flutter run -d windows
```

## Testing Storage Modes

### Private Mode (Default)
1. Keep "Private" mode selected
2. Enter a key and value
3. Click "Set Value"
4. Data is stored privately for this app only

### Shared Mode (Platform-Specific)

#### iOS/macOS - iCloud Keychain Sync
1. Switch to "Shared" mode
2. **Important**: Configure iCloud capability first (see setup guides)
3. Enter a key and value
4. Click "Set Value"
5. Data syncs in real-time to all devices with same Apple ID

#### Android - Auto Backup
1. Switch to "Shared" mode
2. **Important**: Auto Backup is pre-configured in this example
3. Enter a key and value
4. Click "Set Value"
5. Data backs up automatically to Google Drive (~every 24 hours)
6. Restored automatically when app is reinstalled

#### Windows - Credential Manager
1. Switch to "Shared" mode
2. Enter a key and value
3. Click "Set Value"
4. Data stored in Windows Credential Manager (local machine)

## Configuring Entitlements (for Shared Mode)

### iOS
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to **Signing & Capabilities**
4. Click **+ Capability** → **Keychain Sharing**
5. Add: `$(AppIdentifierPrefix)io.alexmelnyk.crossvault.shared`

### macOS
1. Open `macos/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to **Signing & Capabilities**
4. Click **+ Capability** → **Keychain Sharing**
5. Add: `$(AppIdentifierPrefix)io.alexmelnyk.crossvault.shared`

## Quick Examples

The app includes pre-filled examples:
- **user_token** - JWT token example
- **api_key** - API key example
- **user_email** - Email example

Click the arrow button to auto-fill the fields.

## UI Features

### Platform Information Card
Shows the current platform and version.

### Storage Mode Selector
Toggle between Private and Shared modes with visual indicators.

### Key-Value Input
Enter custom keys and values for testing.

### Operations Buttons
- **Set Value** - Save data
- **Get Value** - Retrieve data
- **Check Exists** - Verify key existence
- **Delete Key** - Remove specific key (orange)
- **Delete All** - Clear all data (red, with confirmation)

### Result Display
Color-coded feedback:
- 🔴 Red - Errors
- 🟢 Green - Success
- 🔵 Blue - Information

## Code Structure

```dart
// Global configuration (optional)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Crossvault.init(
    options: IOSOptions(
      accessGroup: 'io.alexmelnyk.crossvault.shared',
      synchronizable: true,
    ),
  );
  
  runApp(MyApp());
}

// Per-method configuration
final crossvault = Crossvault();

// Private mode
await crossvault.setValue('key', 'value');

// Shared mode (override)
await crossvault.setValue(
  'key',
  'value',
  options: IOSOptions(
    accessGroup: 'io.alexmelnyk.crossvault.shared',
  ),
);
```

## Troubleshooting

### "Keychain operation failed" on iOS/macOS
- Ensure entitlements are configured correctly
- Rebuild the app after changing entitlements
- Check that the access group matches in code and entitlements

### Shared mode not working
- Verify you're using the same Team ID
- Check that both apps have the same access group
- Make sure entitlements file is included in build

### macOS window not frameless
- Clean build: `flutter clean`
- Rebuild: `flutter run -d macos`

## Learn More

- [Crossvault Documentation](../README.md)
- [iOS Setup Guide](../../crossvault_ios/README.md)
- [macOS Setup Guide](../../crossvault_macos/README.md)
