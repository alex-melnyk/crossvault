# crossvault_macos

The macOS implementation of [`crossvault`][1].

## Features

- ✅ Secure storage using macOS Keychain Services
- ✅ Support for Keychain Access Groups (sharing between apps)
- ✅ iCloud Keychain synchronization support
- ✅ Pure Swift implementation
- ✅ Comprehensive error handling

## Usage

This package is [endorsed][2], which means you can simply use `crossvault`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Usage Modes

Crossvault macOS supports two modes of operation:

### 1. **Private Mode (Default)** - No Access Group

Data is stored privately for your app only. No additional setup required.

```dart
// No configuration needed
final crossvault = Crossvault();
await crossvault.setValue('api_token', 'secret_value');

// Or explicitly without access group
await crossvault.setValue(
  'api_token',
  'secret_value',
  options: MacOSOptions(),  // No accessGroup specified
);
```

**Use this when:**
- You don't need to share data between apps
- You want the simplest setup
- You're building a single app

### 2. **Shared Mode** - With Access Group

Data can be shared between apps with the same Team ID.

```dart
await Crossvault.init(
  options: MacOSOptions(
    accessGroup: 'io.alexmelnyk.crossvault.shared',
  ),
);
```

**Use this when:**
- You need to share data between multiple apps
- You want to sync data between your macOS apps

## Keychain Access Groups Setup

**Note:** This setup is only required if you want to use **Shared Mode** with access groups. For private storage, skip this section.

### Step 1: Enable Keychain Sharing in Xcode

1. Open your macOS project in Xcode: `macos/Runner.xcworkspace`
2. Select your target (Runner)
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Add **Keychain Sharing**
6. Add your access group identifier (e.g., `$(AppIdentifierPrefix)io.alexmelnyk.crossvault.shared`)

### Step 2: Configure Entitlements

Xcode will automatically create `macos/Runner/Runner.entitlements`. It should look like this:

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

### Step 3: Use Access Groups in Your Code

#### Option 1: Global Configuration (Recommended)

Initialize Crossvault once at app startup with your global configuration:

```dart
import 'package:crossvault/crossvault.dart';

// In your main() or app initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize with global macOS options
  await Crossvault.init(
    options: MacOSOptions(
      accessGroup: 'io.alexmelnyk.crossvault.shared',
      synchronizable: true,
      accessibility: MacOSAccessibility.afterFirstUnlock,
    ),
  );
  
  runApp(MyApp());
}

// Now use Crossvault anywhere without specifying options
final crossvault = Crossvault();

// All operations use global configuration
await crossvault.setValue('api_token', 'secret_value');
final value = await crossvault.getValue('api_token');
```

#### Option 2: Per-Method Configuration

Override global configuration for specific operations:

```dart
import 'package:crossvault/crossvault.dart';

final crossvault = Crossvault();

// Use different options for specific call
await crossvault.setValue(
  'temp_token',
  'temp_value',
  options: MacOSOptions(
    synchronizable: false,  // Don't sync this one
    accessibility: MacOSAccessibility.whenUnlocked,
  ),
);

// Or use completely different access group
await crossvault.setValue(
  'shared_token',
  'shared_value',
  options: MacOSOptions(
    accessGroup: 'io.alexmelnyk.another.group',
  ),
);
```

#### Option 3: No Global Configuration

Use options on every call:

```dart
import 'package:crossvault/crossvault.dart';

final crossvault = Crossvault();

// Specify options for each operation
await crossvault.setValue(
  'api_token',
  'secret_value',
  options: MacOSOptions(
    accessGroup: 'io.alexmelnyk.crossvault.shared',
    synchronizable: true,
    accessibility: MacOSAccessibility.whenUnlocked,
  ),
);

final value = await crossvault.getValue(
  'api_token',
  options: MacOSOptions(
    accessGroup: 'io.alexmelnyk.crossvault.shared',
  ),
);
```

## Comparison: Private vs Shared Mode

| Feature | Private Mode (No Access Group) | Shared Mode (With Access Group) |
|---------|-------------------------------|----------------------------------|
| **Setup Required** | ❌ None | ✅ Xcode entitlements configuration |
| **Data Sharing** | ❌ App-only | ✅ Between apps with same Team ID |
| **iCloud Sync** | ✅ Optional | ✅ Optional |
| **Security** | 🔒 Highest (app-isolated) | 🔒 High (team-isolated) |
| **Use Case** | Single app | Multiple apps |

### Code Examples

#### Private Mode (Simple)
```dart
// No setup needed
final crossvault = Crossvault();
await crossvault.setValue('token', 'value');
```

#### Shared Mode (Requires entitlements)
```dart
// Setup once
await Crossvault.init(
  options: MacOSOptions(
    accessGroup: 'io.alexmelnyk.crossvault.shared',
  ),
);

// Use anywhere
final crossvault = Crossvault();
await crossvault.setValue('token', 'value');  // Shared with other apps
```

#### Mixed Mode (Both in same app)
```dart
// Global config for shared data
await Crossvault.init(
  options: MacOSOptions(
    accessGroup: 'io.alexmelnyk.crossvault.shared',
  ),
);

final crossvault = Crossvault();

// Shared data (uses global config)
await crossvault.setValue('shared_token', 'value');

// Private data (override to remove access group)
await crossvault.setValue(
  'private_token',
  'value',
  options: MacOSOptions(),  // No accessGroup = private
);
```

### Important Notes

1. **Team ID Prefix**: The `$(AppIdentifierPrefix)` is automatically replaced with your Team ID by Xcode.

2. **Same Team ID**: All apps sharing keychain data must be signed with the same Team ID.

3. **Access Group Format**: 
   - With prefix: `$(AppIdentifierPrefix)com.yourcompany.shared`
   - Full format: `TEAM_ID.com.yourcompany.shared`

4. **Without Access Group**: If you don't specify an access group, data is stored privately for your app only. This is the default and most secure option.

5. **iCloud Sync**: Available in both modes via `synchronizable: true` option.

## Security Features

### Data Protection

- Uses `kSecAttrAccessibleAfterFirstUnlock` by default
- Data is encrypted by macOS Keychain
- Survives app reinstalls (unless explicitly deleted)
- Protected by user password/biometrics

### Access Control

You can customize access control by modifying the `kSecAttrAccessible` attribute in the Swift code:

- `kSecAttrAccessibleWhenUnlocked` - Most secure, only when Mac is unlocked
- `kSecAttrAccessibleAfterFirstUnlock` - Default, balanced security
- `kSecAttrAccessibleAlways` - Least secure, always accessible
- `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` - No iCloud sync
- `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` - No iCloud sync

## Error Handling

The plugin throws `PlatformException` with the following error codes:

- `INVALID_ARGUMENT` - Missing or invalid parameters
- `KEYCHAIN_ERROR` - Keychain operation failed (includes OSStatus details)

Example:

```dart
try {
  await crossvault.setValue('key', 'value');
} on PlatformException catch (e) {
  if (e.code == 'KEYCHAIN_ERROR') {
    print('Keychain error: ${e.message}');
  }
}
```

## FAQ

### Do I need to configure entitlements?

**No**, only if you want to use **Shared Mode** (access groups). For private storage, no configuration is needed.

### Can I use both private and shared storage in the same app?

**Yes!** Use global config for one mode, and override with `options` parameter for the other:

```dart
// Global: shared mode
await Crossvault.init(
  options: MacOSOptions(accessGroup: 'shared.group'),
);

// Shared (uses global)
await crossvault.setValue('shared_key', 'value');

// Private (override)
await crossvault.setValue(
  'private_key',
  'value',
  options: MacOSOptions(),  // No accessGroup = private
);
```

### What happens if I specify an access group without configuring entitlements?

The keychain operation will fail with an error. You must configure entitlements in Xcode if you want to use access groups.

### Is private mode more secure than shared mode?

**Yes**, slightly. Private mode isolates data to your app only, while shared mode allows access from other apps with the same Team ID and access group. Both are encrypted by macOS Keychain.

## Troubleshooting

### "Keychain operation failed" errors

1. Check that your app is properly signed
2. Verify entitlements are correctly configured (if using access groups)
3. Ensure access group names match exactly
4. Check that all apps use the same Team ID

### Access Group not working

1. Verify the access group is listed in entitlements
2. Check that `$(AppIdentifierPrefix)` is used in entitlements
3. Ensure both apps have the same access group configured
4. Rebuild the app after changing entitlements

### I don't want to use access groups, do I need to do anything?

**No!** Just use Crossvault without specifying `accessGroup` in `MacOSOptions`. Data will be stored privately for your app.

[1]: ../crossvault
[2]: https://flutter.dev/to/endorsed-federated-plugin
