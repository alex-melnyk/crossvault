# crossvault_android

The Android implementation of [`crossvault`][1].

## Features

- ✅ **EncryptedSharedPreferences** - AndroidX Security library
- ✅ **Android Keystore** - Hardware-backed key storage
- ✅ **AES256-GCM Encryption** - Industry-standard encryption
- ✅ **Auto Backup** - Automatic backup to Google Drive
- ✅ **Auto Restore** - Data restored after app reinstall
- ✅ **Error Recovery** - Automatic reset on decryption failure

## Usage

This package is [endorsed][2], which means you can simply use `crossvault`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## How It Works

### 1. **EncryptedSharedPreferences**

Uses AndroidX Security library for encryption:
- **Keys**: Encrypted with AES256-SIV
- **Values**: Encrypted with AES256-GCM
- **Master Key**: Stored in Android Keystore

```kotlin
// Master key stored in Android Keystore
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

// Encrypted SharedPreferences
val encryptedPrefs = EncryptedSharedPreferences.create(
    context,
    "crossvault_secure_storage",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)
```

### 2. **Android Keystore**

Master encryption key is stored in Android Keystore:
- **Hardware-backed** on supported devices (TEE/SE)
- **System-protected** - cannot be extracted
- **Survives app reinstall** when using Auto Backup
- **Invalidated** when device security changes

### 3. **Auto Backup**

Automatic backup to Google Drive:
- **Enabled by default** in Android 6.0+ (API 23+)
- **Up to 25MB** per app
- **Encrypted** in transit and at rest
- **Automatic restore** when app is reinstalled
- **Requires** Google account

## Configuration

### Basic Usage (No Configuration Required)

```dart
import 'package:crossvault/crossvault.dart';

final crossvault = Crossvault();

// Store data (automatically encrypted)
await crossvault.setValue('api_token', 'secret_value');

// Retrieve data
final token = await crossvault.getValue('api_token');
```

### Advanced Configuration

```dart
// Global configuration
await Crossvault.init(
  options: AndroidOptions(
    sharedPreferencesName: 'my_secure_storage',  // Custom storage name
    resetOnError: true,  // Auto-reset on decryption failure
  ),
);

// Per-method configuration
await crossvault.setValue(
  'temp_key',
  'temp_value',
  options: AndroidOptions(
    sharedPreferencesName: 'temp_storage',
    resetOnError: false,  // Don't reset, throw error instead
  ),
);
```

## Auto Backup Setup

### Option 1: Enable Auto Backup (Recommended)

Add to your `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:allowBackup="true"
    android:fullBackupContent="@xml/backup_rules"
    android:dataExtractionRules="@xml/data_extraction_rules">
    <!-- Your app content -->
</application>
```

Create `android/app/src/main/res/xml/backup_rules.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <!-- Include encrypted SharedPreferences -->
    <include domain="sharedpref" path="crossvault_secure_storage.xml"/>
    
    <!-- Exclude master key (will be regenerated) -->
    <exclude domain="sharedpref" path="_androidx_security_master_key_"/>
</full-backup-content>
```

For Android 12+ (API 31+), also create `android/app/src/main/res/xml/data_extraction_rules.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <include domain="sharedpref" path="crossvault_secure_storage.xml"/>
        <exclude domain="sharedpref" path="_androidx_security_master_key_"/>
    </cloud-backup>
</data-extraction-rules>
```

### Option 2: Disable Auto Backup

If you don't want automatic backups:

```xml
<application
    android:allowBackup="false">
    <!-- Your app content -->
</application>
```

## How Auto Backup Works

### Backup Process

1. **Automatic** - Android backs up data ~every 24 hours
2. **Encrypted** - Data encrypted before upload to Google Drive
3. **Incremental** - Only changed data is backed up
4. **Quota** - Up to 25MB per app

### Restore Process

1. **Automatic** - When app is reinstalled on same device or new device
2. **Same Google Account** - User must be signed in with same account
3. **Master Key Regenerated** - New master key created in Keystore
4. **Data Decrypted** - Backed up data decrypted with new key

### Important Notes

⚠️ **Master Key is NOT backed up** - It's regenerated on restore
✅ **Encrypted data IS backed up** - SharedPreferences file is backed up
✅ **Works across devices** - Restore on any device with same Google account
⚠️ **Requires Google Play Services** - Not available on devices without GPS

## Error Handling

### Automatic Reset on Error

When `resetOnError: true` (default), the plugin automatically handles:

- **Device security changes** (lock screen added/removed)
- **Key invalidation** (master key invalidated by system)
- **Data corruption** (encrypted file corrupted)

```dart
AndroidOptions(
  resetOnError: true,  // Auto-reset and recreate storage
)
```

### Manual Error Handling

When `resetOnError: false`, errors are thrown:

```dart
try {
  await crossvault.setValue('key', 'value', 
    options: AndroidOptions(resetOnError: false),
  );
} on PlatformException catch (e) {
  if (e.code == 'STORAGE_ERROR') {
    print('Storage error: ${e.message}');
    // Handle manually
  }
}
```

## Security Features

### Encryption

- **Algorithm**: AES256-GCM for values, AES256-SIV for keys
- **Key Storage**: Android Keystore (hardware-backed when available)
- **Key Generation**: Cryptographically secure random
- **Key Rotation**: Not supported (would require re-encryption)

### Hardware Security

On supported devices:
- **TEE** (Trusted Execution Environment) - Secure processor
- **SE** (Secure Element) - Dedicated security chip
- **StrongBox** - Hardware security module (Android 9+)

Check device support:
```kotlin
val keyInfo = masterKey.keyInfo
val isInsideSecureHardware = keyInfo.isInsideSecureHardware
```

### Data Protection

- **At Rest**: Encrypted on device storage
- **In Transit**: Encrypted when backed up to Google Drive
- **In Memory**: Decrypted only when accessed
- **On Uninstall**: Deleted (unless backed up)

## Requirements

- **Minimum SDK**: Android 6.0 (API 23)
- **Target SDK**: Android 14 (API 34)
- **Dependencies**: 
  - `androidx.security:security-crypto:1.1.0-alpha06`

## Limitations

### Auto Backup Limitations

- ❌ **Not real-time** - Backup happens ~every 24 hours
- ❌ **25MB limit** - Per app quota
- ❌ **Requires Google account** - User must be signed in
- ❌ **Requires Google Play Services** - Not available on all devices
- ❌ **User can disable** - Backup can be disabled in system settings

### Encryption Limitations

- ❌ **No key rotation** - Master key cannot be rotated
- ❌ **No biometric binding** - Key not bound to biometrics
- ❌ **No user authentication** - No PIN/password required

## Comparison with iOS/macOS

| Feature | Android | iOS/macOS |
|---------|---------|-----------|
| **Encryption** | AES256-GCM | AES256-GCM |
| **Key Storage** | Android Keystore | iOS Keychain |
| **Hardware Security** | TEE/SE/StrongBox | Secure Enclave |
| **Auto Backup** | Google Drive | iCloud Keychain |
| **Sync Between Devices** | Via backup | Real-time (iCloud) |
| **Restore After Reinstall** | ✅ Yes | ✅ Yes |
| **Requires Account** | Google | Apple ID |

## Troubleshooting

### "STORAGE_ERROR" on first access

**Cause**: Failed to create EncryptedSharedPreferences

**Solution**:
1. Check minimum SDK is 23+
2. Ensure device has lock screen enabled
3. Try with `resetOnError: true`

### Data lost after device security change

**Cause**: Master key invalidated when lock screen removed

**Solution**:
- Enable Auto Backup to restore data
- Or use `resetOnError: true` to recreate storage

### Backup not working

**Cause**: Auto Backup disabled or not configured

**Solution**:
1. Check `android:allowBackup="true"` in manifest
2. Verify backup rules XML exists
3. Ensure user has Google account
4. Check device has Google Play Services

### Data not restored after reinstall

**Cause**: Different Google account or backup not completed

**Solution**:
1. Sign in with same Google account
2. Wait for backup to complete (~24 hours)
3. Check backup quota not exceeded

## Best Practices

### 1. Use Default Settings

```dart
// Simple and secure
final crossvault = Crossvault();
await crossvault.setValue('key', 'value');
```

### 2. Enable Auto Backup

Configure backup rules for automatic restore after reinstall.

### 3. Handle Errors Gracefully

```dart
try {
  await crossvault.setValue('key', 'value');
} catch (e) {
  // Log error and inform user
}
```

### 4. Don't Store Large Data

- Keep values small (< 1KB recommended)
- Use for tokens, keys, passwords only
- Not suitable for large files or databases

### 5. Test Backup/Restore

```bash
# Force backup
adb shell bmgr backupnow <package_name>

# List backups
adb shell bmgr list transports

# Restore from backup
adb shell bmgr restore <package_name>
```

## Learn More

- [Android Keystore System](https://developer.android.com/training/articles/keystore)
- [EncryptedSharedPreferences](https://developer.android.com/reference/androidx/security/crypto/EncryptedSharedPreferences)
- [Auto Backup](https://developer.android.com/guide/topics/data/autobackup)
- [Data Extraction Rules](https://developer.android.com/about/versions/12/backup-restore)

[1]: ../crossvault
[2]: https://flutter.dev/to/endorsed-federated-plugin
