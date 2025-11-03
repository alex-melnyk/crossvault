# Windows Credential Manager - Quick Setup

Quick reference for using Windows Credential Manager with optional TPM support in your Windows app.

## ⚡ Basic Setup (No Configuration Needed)

Windows Credential Manager works out of the box with DPAPI encryption:

```dart
import 'package:crossvault/crossvault.dart';

final crossvault = Crossvault();

// Store data (automatically encrypted with DPAPI)
await crossvault.setValue('api_token', 'secret_value');

// Retrieve data
final token = await crossvault.getValue('api_token');
```

## 🔧 Advanced Configuration

### With Custom Prefix

```dart
await Crossvault.init(
  config: CrossvaultConfig(
    windows: WindowsOptions(
      prefix: 'myapp',  // Custom prefix for organization
      persist: WindowsPersist.localMachine,
    ),
  ),
);
```

### With TPM (Hardware Security)

```dart
await Crossvault.init(
  config: CrossvaultConfig(
    windows: WindowsOptions(
      prefix: 'myapp',
      persist: WindowsPersist.localMachine,
      useTPM: true,  // Enable TPM if available
    ),
  ),
);
```

## 🔐 Persist Types

### Session (Temporary)
```dart
WindowsOptions(
  persist: WindowsPersist.session,  // Until user logs out
)
```

### Local Machine (Default)
```dart
WindowsOptions(
  persist: WindowsPersist.localMachine,  // Permanent
)
```

### Enterprise (AD Roaming)
```dart
WindowsOptions(
  persist: WindowsPersist.enterprise,  // Roams with AD profile
)
```

## 🛡️ TPM Support

### What is TPM?

**TPM (Trusted Platform Module)** provides hardware-backed security similar to iOS Secure Enclave:
- 🔒 Keys stored in hardware chip
- 🛡️ Cannot be extracted
- 🔐 Device-bound security

### Enabling TPM

```dart
WindowsOptions(
  useTPM: true,  // Automatically falls back to DPAPI if unavailable
)
```

### Check TPM Availability

```powershell
# PowerShell
Get-Tpm

# Output:
# TpmPresent : True
# TpmReady   : True
```

### When to Use TPM

#### ✅ Use TPM for:
- 🔑 Master keys
- 💳 Payment credentials
- 🏢 Enterprise secrets
- 🔐 Critical passwords

#### ❌ Don't use TPM for:
- 📝 Cache data
- 🔄 Data that needs to roam
- ⚡ High-frequency operations (TPM is slower)

## 🎯 Common Patterns

### Mixed Security Levels

```dart
// Global config - standard security
await Crossvault.init(
  config: CrossvaultConfig(
    windows: WindowsOptions(
      prefix: 'myapp',
      persist: WindowsPersist.localMachine,
      useTPM: false,
    ),
  ),
);

// Standard data
await crossvault.setValue('user_preferences', 'value');

// Critical data with TPM
await crossvault.setValue(
  'master_key',
  'very_secret',
  config: CrossvaultConfig(
    windows: WindowsOptions(useTPM: true),
  ),
);
```

### Session vs Persistent

```dart
// Session token (temporary)
await crossvault.setValue(
  'session_token',
  'temp_value',
  config: CrossvaultConfig(
    windows: WindowsOptions(
      persist: WindowsPersist.session,
    ),
  ),
);

// API key (persistent)
await crossvault.setValue(
  'api_key',
  'permanent_value',
  config: CrossvaultConfig(
    windows: WindowsOptions(
      persist: WindowsPersist.localMachine,
    ),
  ),
);
```

## 🔍 Viewing Stored Credentials

### Windows Credential Manager UI

1. Press `Win + R`
2. Type: `control /name Microsoft.CredentialManager`
3. Navigate to **Windows Credentials** → **Generic Credentials**
4. Look for entries: `io.alexmelnyk.crossvault:*` or `yourprefix:*`

**Note**: Only credential names are visible, values are encrypted.

## 📊 Performance

| Operation | DPAPI | TPM |
|-----------|-------|-----|
| **Speed** | ⚡⚡⚡⚡⚡ Fast (1-5ms) | ⚡⚡ Slower (100-300ms) |
| **Security** | ⭐⭐⭐⭐ Software | ⭐⭐⭐⭐⭐ Hardware |
| **Portability** | ✅ With profile | ❌ Device-bound |

## ⚠️ Important Notes

### DPAPI (Default)
- ✅ Fast performance
- ✅ User-bound encryption
- ✅ Can roam with user profile
- ⚠️ Software-based security

### TPM (Optional)
- ✅ Hardware security
- ✅ Keys never leave chip
- ⚠️ Slower performance
- ⚠️ Device-specific (lost on hardware change)

## 🐛 Troubleshooting

### Credential not found after restart

**Cause**: Using `WindowsPersist.session`

**Solution**: Use `WindowsPersist.localMachine`

```dart
WindowsOptions(persist: WindowsPersist.localMachine)
```

### TPM not available

**Cause**: No TPM chip or disabled

**Solution**: App automatically falls back to DPAPI
```dart
WindowsOptions(useTPM: true)  // Safe to use always
```

### Data lost after hardware change

**Cause**: TPM keys are hardware-bound

**Solution**: Don't use TPM for portable data
```dart
WindowsOptions(useTPM: false)  // For portable data
```

## 📚 Full Documentation

- [Windows Plugin README](../crossvault_windows/README.md)
- [Main Package README](README.md)

## 🎯 Quick Comparison

| Feature | Windows | iOS/macOS | Android |
|---------|---------|-----------|---------|
| **Storage** | Credential Manager | Keychain | Keystore |
| **Encryption** | DPAPI/TPM | Secure Enclave | TEE/SE |
| **Cloud Sync** | ❌ (AD only) | ✅ iCloud | ❌ (Backup) |
| **Hardware** | ⚠️ TPM optional | ✅ Always | ✅ When available |
| **UI Access** | ✅ Credential Manager | ✅ Keychain Access | ❌ |

## 💡 Best Practices

### 1. Choose Appropriate Security Level

```dart
// Low security - cache
WindowsOptions(
  useTPM: false,
  persist: WindowsPersist.session,
)

// Medium security - general data
WindowsOptions(
  useTPM: false,
  persist: WindowsPersist.localMachine,
)

// High security - critical secrets
WindowsOptions(
  useTPM: true,
  persist: WindowsPersist.localMachine,
)
```

### 2. Use Prefixes for Organization

```dart
WindowsOptions(prefix: 'myapp')           // General
WindowsOptions(prefix: 'myapp.auth')      // Authentication
WindowsOptions(prefix: 'myapp.cache')     // Cache
```

### 3. Clean Up on Logout

```dart
// Delete all app credentials
await crossvault.deleteAll();
```

### 4. Handle Errors Gracefully

```dart
try {
  await crossvault.setValue('key', 'value');
} on PlatformException catch (e) {
  if (e.code == 'CREDENTIAL_ERROR') {
    print('Failed to save: ${e.message}');
  }
}
```

## 🚀 Ready to Use!

Windows Credential Manager is ready to use with zero configuration. Add TPM for critical data when needed.

```dart
// That's it! Start using:
await crossvault.setValue('my_key', 'my_value');
```
