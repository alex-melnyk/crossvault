# crossvault_windows

The Windows implementation of [`crossvault`][1].

## Features

- ✅ **Windows Credential Manager** - Native Windows secure storage
- ✅ **DPAPI Encryption** - Automatic encryption via Data Protection API
- ✅ **TPM Support** - Optional hardware-backed security (like iOS Secure Enclave)
- ✅ **User-bound Security** - Data encrypted with user's Windows credentials
- ✅ **Multiple Persist Types** - Session, Local Machine, or Enterprise (AD roaming)
- ✅ **UI Integration** - Credentials visible in Windows Credential Manager
- ✅ **Automatic Fallback** - Falls back to DPAPI if TPM unavailable

## Usage

This package is [endorsed][2], which means you can simply use `crossvault`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## How It Works

### 1. **Windows Credential Manager**

Uses native Windows Credential Manager API for secure storage:
- **API**: `wincred.h` (CredWrite, CredRead, CredDelete, CredEnumerate)
- **Encryption**: DPAPI (Data Protection API) - automatic
- **Storage**: System-protected credential vault
- **Access**: Only the current Windows user can decrypt

```cpp
// Internally uses Windows API
CREDENTIAL credential = {0};
credential.Type = CRED_TYPE_GENERIC;
credential.TargetName = L"io.alexmelnyk.crossvault:mykey";
credential.CredentialBlob = encryptedData;
credential.Persist = CRED_PERSIST_LOCAL_MACHINE;

CredWriteW(&credential, 0);
```

### 2. **DPAPI Encryption**

Data is automatically encrypted by Windows:
- **User-bound** - Encrypted with user's Windows login credentials
- **Automatic** - No manual encryption needed
- **Secure** - Cannot be decrypted by other users
- **Persistent** - Survives app reinstall

### 3. **Credential Manager UI**

Users can view stored credentials:
1. Press `Win + R`
2. Type: `control /name Microsoft.CredentialManager`
3. Navigate to **Windows Credentials** → **Generic Credentials**
4. Look for entries starting with `io.alexmelnyk.crossvault:`

**Note**: Only the credential name is visible, the value is encrypted.

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
  config: CrossvaultConfig(
    windows: WindowsOptions(
      prefix: 'myapp',  // Custom prefix for credential names
      persist: WindowsPersist.localMachine,  // Persist type
      useTPM: false,  // Use TPM for hardware-backed security
    ),
  ),
);

// Per-method configuration
await crossvault.setValue(
  'temp_key',
  'temp_value',
  config: CrossvaultConfig(
    windows: WindowsOptions(
      prefix: 'temp',
      persist: WindowsPersist.session,  // Only for current session
    ),
  ),
);

// Use TPM for critical data
await crossvault.setValue(
  'master_key',
  'very_secret',
  config: CrossvaultConfig(
    windows: WindowsOptions(
      useTPM: true,  // Hardware-backed security
    ),
  ),
);
```

## Persist Types

### `WindowsPersist.session`
- **Lifetime**: Current Windows session only
- **Survives**: Until user logs out
- **Use case**: Temporary data, session tokens

### `WindowsPersist.localMachine` (Default)
- **Lifetime**: Permanent (until deleted)
- **Survives**: App reinstall, system restart
- **Use case**: API tokens, user preferences

### `WindowsPersist.enterprise`
- **Lifetime**: Permanent with AD roaming
- **Survives**: Roams to other domain-joined machines
- **Use case**: Enterprise environments with Active Directory
- **Requires**: Domain-joined Windows machine

## TPM Support

### What is TPM?

**TPM (Trusted Platform Module)** is a hardware security chip that provides:
- 🔒 Hardware-backed key storage (keys never leave the chip)
- 🛡️ Protection against software attacks
- 🔐 Similar to iOS Secure Enclave or Android StrongBox

### Enabling TPM

```dart
WindowsOptions(
  useTPM: true,  // Enable TPM if available
)
```

### How It Works

1. **Check Availability**: Automatically checks if TPM is present
2. **Encrypt with TPM**: If available, uses TPM for encryption
3. **Fallback to DPAPI**: If unavailable, uses standard DPAPI
4. **Transparent**: No code changes needed, works automatically

### Requirements

- ✅ Windows 7 or later
- ✅ TPM 1.2 or 2.0 chip installed
- ✅ TPM enabled in BIOS/UEFI
- ✅ TPM initialized and ready

### Check TPM Availability

```powershell
# PowerShell
Get-Tpm

# Output:
# TpmPresent : True
# TpmReady   : True
# TpmEnabled : True
```

### When to Use TPM

#### ✅ Use TPM for:
- 🔑 **Master keys** - Encryption keys, root passwords
- 💳 **Payment data** - Credit card info, payment tokens
- 🏢 **Enterprise secrets** - Company credentials, certificates
- 🔐 **Sensitive credentials** - Admin passwords, API keys

#### ❌ Don't use TPM for:
- 📝 **Cache data** - Temporary, non-critical data
- 🔄 **Sync tokens** - Data that needs to roam between devices
- 📊 **Analytics data** - Non-sensitive information
- ⚡ **High-frequency data** - TPM is slower than DPAPI

### Performance Considerations

| Operation | DPAPI | TPM |
|-----------|-------|-----|
| **Encrypt** | ~1-5ms | ~100-300ms |
| **Decrypt** | ~1-5ms | ~100-300ms |
| **Use case** | General data | Critical secrets |

### TPM vs DPAPI

```dart
// For general data - fast, user-bound
WindowsOptions(useTPM: false)  // DPAPI
// ✅ Fast
// ✅ Can roam with user profile
// ⚠️ Software-based security

// For critical data - slow, hardware-bound
WindowsOptions(useTPM: true)   // TPM
// ✅ Hardware security
// ✅ Keys never leave TPM chip
// ⚠️ Slower performance
// ⚠️ Device-specific (cannot roam)
```

## Security Features

### Encryption

#### With DPAPI (default):
- **Algorithm**: DPAPI (AES-256 internally)
- **Key Storage**: Windows LSA (Local Security Authority)
- **Key Binding**: User's Windows login credentials
- **Protection**: Cannot be decrypted by other users
- **Portability**: Can roam with user profile

#### With TPM (optional):
- **Algorithm**: RSA-2048 (via TPM)
- **Key Storage**: TPM hardware chip
- **Key Binding**: Device-specific, cannot be extracted
- **Protection**: Hardware-level security
- **Portability**: Device-bound, cannot roam

### What's Encrypted

- ✅ **CredentialBlob** (value) - Fully encrypted by DPAPI
- ❌ **TargetName** (key) - Visible in Credential Manager
- ❌ **Comment** - Visible in Credential Manager

### Security Best Practices

```dart
// ✅ Good - Use default prefix
await crossvault.setValue('api_token', 'secret');
// Stored as: io.alexmelnyk.crossvault:api_token

// ✅ Good - Use custom prefix for organization
WindowsOptions(prefix: 'myapp')
// Stored as: myapp:api_token

// ⚠️ Avoid - Don't put sensitive data in key names
await crossvault.setValue('user_password_123', 'secret');
// Key name is visible!

// ✅ Better - Use generic key names
await crossvault.setValue('user_credential', 'secret');
```

## Requirements

- **Minimum**: Windows Vista (6.0)
- **Recommended**: Windows 10/11
- **API**: Windows Credential Manager (wincred.h)
- **Dependencies**: None (uses native Windows API)

## Limitations

### Storage Limitations

- ❌ **No cloud sync** - Data stays on local machine (except Enterprise with AD)
- ❌ **User-bound** - Cannot share between Windows users (DPAPI)
- ❌ **Device-bound** - Cannot transfer between machines (TPM)
- ⚠️ **Size limit** - CredentialBlob limited to ~2.5KB per credential
- ⚠️ **TPM performance** - Slower than DPAPI (~100-300ms vs 1-5ms)

### Platform Limitations

- ❌ **Windows only** - Not available on other platforms
- ❌ **Requires user login** - Data encrypted with user credentials
- ⚠️ **Profile-dependent** - Lost if Windows user profile is deleted

## Comparison with Other Platforms

| Feature | Windows (DPAPI) | Windows (TPM) | iOS/macOS | Android |
|---------|-----------------|---------------|-----------|---------|
| **Encryption** | DPAPI (AES-256) | RSA-2048 | AES-256-GCM | AES-256-GCM |
| **Key Storage** | LSA | TPM chip | Keychain | Keystore |
| **Hardware Security** | ❌ | ✅ TPM | ✅ Secure Enclave | ✅ TEE/SE |
| **Cloud Sync** | ❌ (except AD) | ❌ | ✅ iCloud | ❌ (backup only) |
| **UI Integration** | ✅ Credential Manager | ✅ Credential Manager | ✅ Keychain Access | ❌ |
| **Persist Types** | 3 types | 3 types | N/A | N/A |
| **Performance** | ⚡⚡⚡⚡⚡ | ⚡⚡ | ⚡⚡⚡⚡ | ⚡⚡⚡⚡ |
| **Portability** | ✅ With profile | ❌ Device-bound | ✅ iCloud | ⚠️ Backup only |

## Troubleshooting

### Credential not found after restart

**Cause**: Using `WindowsPersist.session`

**Solution**: Use `WindowsPersist.localMachine` for persistent storage

```dart
WindowsOptions(persist: WindowsPersist.localMachine)
```

### Access denied error

**Cause**: Insufficient permissions or corrupted user profile

**Solution**: 
1. Run app as current user (not admin)
2. Check Windows user profile is not corrupted
3. Try deleting and recreating the credential

### Credential Manager shows old values

**Cause**: Cached credentials in UI

**Solution**: Refresh Credential Manager or restart it

### Size limit exceeded

**Cause**: Value larger than ~2.5KB

**Solution**: 
1. Split large data into multiple keys
2. Store reference/ID instead of full data
3. Use file storage for large data

### TPM not available

**Cause**: No TPM chip or TPM disabled

**Solution**:
```dart
// App will automatically fall back to DPAPI
WindowsOptions(useTPM: true)  // Safe to use always

// Or check TPM availability first (in production)
// The plugin handles this automatically
```

### TPM data lost after hardware change

**Cause**: TPM keys are bound to the hardware

**Solution**: 
- Don't use TPM for data that needs to survive hardware changes
- Use DPAPI for portable data
- Implement backup/recovery mechanism for critical TPM data

```dart
// For portable data
WindowsOptions(useTPM: false)

// For device-bound data
WindowsOptions(useTPM: true)
```

## Best Practices

### 1. Use Appropriate Persist Type

```dart
// For session tokens
WindowsOptions(persist: WindowsPersist.session)

// For API keys (default)
WindowsOptions(persist: WindowsPersist.localMachine)

// For enterprise roaming
WindowsOptions(persist: WindowsPersist.enterprise)
```

### 2. Use Prefixes for Organization

```dart
// Group credentials by app/feature
WindowsOptions(prefix: 'myapp')
WindowsOptions(prefix: 'myapp.auth')
WindowsOptions(prefix: 'myapp.cache')
```

### 3. Handle Errors Gracefully

```dart
try {
  await crossvault.setValue('key', 'value');
} on PlatformException catch (e) {
  if (e.code == 'CREDENTIAL_ERROR') {
    print('Failed to save: ${e.message}');
    // Handle error
  }
}
```

### 4. Clean Up on Logout

```dart
// Delete all app credentials
await crossvault.deleteAll();

// Or delete specific credentials
await crossvault.deleteValue('api_token');
```

### 5. Choose Security Level Wisely

```dart
// Low security - cache, temporary data
WindowsOptions(
  useTPM: false,
  persist: WindowsPersist.session,
)

// Medium security - general app data
WindowsOptions(
  useTPM: false,
  persist: WindowsPersist.localMachine,
)

// High security - critical secrets
WindowsOptions(
  useTPM: true,
  persist: WindowsPersist.localMachine,
)

// Enterprise - roaming credentials
WindowsOptions(
  useTPM: false,  // TPM doesn't roam
  persist: WindowsPersist.enterprise,
)
```

## Implementation Details

### Target Name Format

```
[prefix]:[key]

Examples:
- io.alexmelnyk.crossvault:api_token (default)
- myapp:api_token (custom prefix)
- myapp.auth:user_token (nested prefix)
```

### UTF-8 Support

- ✅ Full UTF-8 support for keys and values
- ✅ Automatic conversion to/from Windows wide strings
- ✅ Unicode characters supported

### Memory Management

- ✅ Automatic cleanup with `CredFree()`
- ✅ No memory leaks
- ✅ Efficient string conversions
- ✅ Proper TPM handle cleanup with `NCryptFreeObject()`

### TPM Implementation

Uses Windows CNG (Cryptography Next Generation) API:

```cpp
// Check TPM availability
NCryptOpenStorageProvider(&hProvider, MS_PLATFORM_CRYPTO_PROVIDER, 0);

// Create/open persistent key in TPM
NCryptCreatePersistedKey(hProvider, &hKey, BCRYPT_RSA_ALGORITHM, L"CrossvaultTPMKey", 0, 0);

// Encrypt with TPM
NCryptEncrypt(hKey, data, dataSize, nullptr, encrypted, encryptedSize, &result, NCRYPT_PAD_PKCS1_FLAG);

// Decrypt with TPM
NCryptDecrypt(hKey, encrypted, encryptedSize, nullptr, decrypted, decryptedSize, &result, NCRYPT_PAD_PKCS1_FLAG);
```

### Credential Type Detection

The plugin automatically detects encryption type by checking the `UserName` field:

```cpp
// TPM-encrypted credentials
credential.UserName = L"crossvault_tpm"

// DPAPI-encrypted credentials
credential.UserName = L"crossvault"
```

This allows seamless migration between TPM and DPAPI without data loss.

## Additional Resources

- [Windows Credential Manager API](https://docs.microsoft.com/en-us/windows/win32/api/wincred/)
- [DPAPI Documentation](https://docs.microsoft.com/en-us/windows/win32/seccng/cng-dpapi)
- [TPM and CNG](https://docs.microsoft.com/en-us/windows/win32/seccng/cng-portal)
- [NCrypt API Reference](https://docs.microsoft.com/en-us/windows/win32/api/ncrypt/)
- [Crossvault Main Package](../crossvault)

[1]: ../crossvault
[2]: https://flutter.dev/to/endorsed-federated-plugin
