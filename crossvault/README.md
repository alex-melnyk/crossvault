<div align="center">
  <img src="logo.svg" alt="Crossvault Logo" width="200"/>
  
  # Crossvault
  
  **Secure cross-platform vault for Flutter**
  
  [![pub package](https://img.shields.io/pub/v/crossvault.svg)](https://pub.dev/packages/crossvault)
  [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
  
  A unified API for secure storage across Android, iOS, macOS, and Windows.
</div>

---

## 📦 Packages

This repository contains multiple packages that work together to provide a federated plugin architecture:

| Package | Description | Version |
|---------|-------------|---------|
| [crossvault]() | The main app-facing package | 1.0.0 |
| [crossvault_platform_interface](../crossvault_platform_interface) | Common platform interface | 1.0.0 |
| [crossvault_android](../crossvault_android) | Android implementation | 1.0.0 |
| [crossvault_ios](../crossvault_ios) | iOS implementation | 1.0.0 |
| [crossvault_macos](../crossvault_macos) | macOS implementation | 1.0.0 |
| [crossvault_windows](../crossvault_windows) | Windows implementation | 1.0.0 |

## ✨ Features

- 🔐 **Secure Storage**: Platform-native secure storage mechanisms
  - iOS/macOS: Keychain Services with Secure Enclave
  - Android: EncryptedSharedPreferences with Keystore
  - Windows: Credential Manager with DPAPI
- 🛡️ **Hardware Security**: Optional hardware-backed encryption
  - iOS/macOS: Secure Enclave (always)
  - Android: TEE/SE/StrongBox (when available)
  - Windows: TPM (Trusted Platform Module) - optional
- 🔄 **Cross-platform API**: Unified API across all platforms
- 🎯 **Type-safe Configuration**: Platform-specific options with type safety
- 🌐 **Keychain Sharing**: iOS/macOS support for sharing data between apps
- ☁️ **iCloud Sync**: Real-time iCloud Keychain synchronization (iOS/macOS)
- 📦 **Auto Backup**: Automatic backup to Google Drive (Android)
- 🏗️ **Federated Architecture**: Clean separation of platform implementations

## 🚀 Quick Start

### Installation

Add `crossvault` to your `pubspec.yaml`:

```yaml
dependencies:
  crossvault: ^1.0.0
```

### Basic Usage

```dart
import 'package:crossvault/crossvault.dart';

final crossvault = Crossvault();

// Store a value
await crossvault.setValue('api_token', 'secret_value');

// Retrieve a value
final token = await crossvault.getValue('api_token');
print('Token: $token');

// Check if key exists
final exists = await crossvault.existsKey('api_token');

// Delete a value
await crossvault.deleteValue('api_token');

// Delete all values
await crossvault.deleteAll();
```

### Global Configuration (Recommended)

Initialize Crossvault once at app startup with settings for all platforms:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure all platforms at once
  await Crossvault.init(
    config: CrossvaultConfig(
      ios: IOSOptions(
        accessGroup: 'io.alexmelnyk.crossvault.shared',
        synchronizable: true,  // Enable iCloud Keychain sync
        accessibility: IOSAccessibility.afterFirstUnlock,
      ),
      macos: MacOSOptions(
        accessGroup: 'io.alexmelnyk.crossvault.shared',
        synchronizable: true,  // Enable iCloud Keychain sync
        accessibility: MacOSAccessibility.afterFirstUnlock,
      ),
      android: AndroidOptions(
        sharedPreferencesName: 'my_secure_prefs',
        resetOnError: true,  // Auto-reset on decryption error
      ),
      windows: WindowsOptions(
        prefix: 'crossvault',
        persist: WindowsPersist.localMachine,
      ),
    ),
  );
  
  runApp(MyApp());
}

// Now use Crossvault anywhere - it automatically uses the right platform config
final crossvault = Crossvault();
await crossvault.setValue('key', 'value');  // Uses platform-specific config
```

**Note:** Configure iCloud for iOS/macOS and Auto Backup for Android. See setup guides below.

### Per-Method Configuration

Override global configuration for specific operations:

```dart
// Global config is used by default
await crossvault.setValue('normal_key', 'value');

// Override for specific operation
await crossvault.setValue(
  'temp_key',
  'temp_value',
  options: IOSOptions(
    synchronizable: false,  // Don't sync this one
  ),
);
```

## 🏗️ Architecture

This plugin follows Flutter's federated plugin architecture, which provides:

- **Separation of concerns**: Each platform has its own package
- **Independent versioning**: Platform implementations can be updated independently
- **Better maintainability**: Easier to test and maintain platform-specific code
- **Flexibility**: Users can depend on specific platform implementations if needed

### How it works

```
┌─────────────────┐
│   Your App      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   crossvault    │  ◄── App-facing API
└────────┬────────┘
         │
         ▼
┌──────────────────────────┐
│ crossvault_platform_     │  ◄── Common interface
│      interface           │
└────────┬─────────────────┘
         │
    ┌────┴────┬────────┬────────┬─────────┐
    ▼         ▼        ▼        ▼         ▼
┌────────┐ ┌─────┐ ┌───────┐ ┌─────────┐
│Android │ │ iOS │ │ macOS │ │ Windows │  ◄── Platform implementations
└────────┘ └─────┘ └───────┘ └─────────┘
```

## 🛠️ Development

### Prerequisites

- Flutter SDK (^3.3.0)
- Dart SDK (^3.9.2)

### Building

Each package can be built independently:

```bash
# Build platform interface
cd crossvault_platform_interface
flutter pub get

# Build Android implementation
cd ../crossvault_android
flutter pub get

# Build main package
cd ../crossvault
flutter pub get
```

### Testing

Run the example app:

```bash
cd crossvault/example
flutter run
```

## 📚 Setup Guides

### Quick Reference Guides
- [iOS/macOS iCloud Sync Quick Setup](IOS_MACOS_ICLOUD_SYNC_QUICK.md) - Real-time sync setup
- [Android Auto Backup Quick Setup](ANDROID_SETUP_QUICK.md) - Backup configuration
- [Windows Credential Manager Quick Setup](WINDOWS_SETUP_QUICK.md) - DPAPI and TPM setup

### Detailed Platform Guides
- [iOS iCloud Sync Setup](example/ios/SETUP_ICLOUD_SYNC.md)
- [macOS iCloud Sync Setup](example/macos/SETUP_ICLOUD_SYNC.md)
- [Android Auto Backup Setup](example/android/SETUP_AUTO_BACKUP.md)

### Platform READMEs
- [iOS Plugin README](../crossvault_ios/README.md)
- [macOS Plugin README](../crossvault_macos/README.md)
- [Android Plugin README](../crossvault_android/README.md)
- [Windows Plugin README](../crossvault_windows/README.md)

## 📝 License

MIT License

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
