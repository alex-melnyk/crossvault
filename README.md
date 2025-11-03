# Crossvault

A secure cross-platform vault plugin for Flutter that provides a unified API for secure storage across Android, iOS, macOS, and Windows.

## 📦 Packages

This repository contains multiple packages that work together to provide a federated plugin architecture:

| Package | Description | Version |
|---------|-------------|---------|
| [crossvault](./crossvault) | The main app-facing package | 0.0.1 |
| [crossvault_platform_interface](./crossvault_platform_interface) | Common platform interface | 0.0.1 |
| [crossvault_android](./crossvault_android) | Android implementation | 0.0.1 |
| [crossvault_ios](./crossvault_ios) | iOS implementation | 0.0.1 |
| [crossvault_macos](./crossvault_macos) | macOS implementation | 0.0.1 |
| [crossvault_windows](./crossvault_windows) | Windows implementation | 0.0.1 |

## ✨ Features

- 🔐 **Secure Storage**: Platform-native secure storage mechanisms
  - iOS/macOS: Keychain Services
  - Android: EncryptedSharedPreferences
  - Windows: Credential Manager
- 🔄 **Cross-platform API**: Unified API across all platforms
- 🎯 **Type-safe Configuration**: Platform-specific options with type safety
- 🌐 **Keychain Sharing**: iOS/macOS support for sharing data between apps
- ☁️ **iCloud Sync**: Optional iCloud Keychain synchronization (iOS/macOS)
- 🏗️ **Federated Architecture**: Clean separation of platform implementations

## 🚀 Quick Start

### Installation

Add `crossvault` to your `pubspec.yaml`:

```yaml
dependencies:
  crossvault: ^0.0.1
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

Initialize Crossvault once at app startup:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // iOS/macOS - Private storage (no sharing)
  // No configuration needed, just use it!
  
  // OR: iOS/macOS with Keychain Access Group (for sharing between apps)
  await Crossvault.init(
    options: IOSOptions(
      accessGroup: 'io.alexmelnyk.crossvault.shared',  // Requires entitlements
      synchronizable: true,  // Enable iCloud sync
      accessibility: IOSAccessibility.afterFirstUnlock,
    ),
  );
  
  // OR: Android with custom preferences
  await Crossvault.init(
    options: AndroidOptions(
      sharedPreferencesName: 'my_secure_prefs',
      resetOnError: true,
    ),
  );
  
  runApp(MyApp());
}

// Now use Crossvault anywhere without specifying options
final crossvault = Crossvault();
await crossvault.setValue('key', 'value');  // Uses global config
```

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

## 📝 License

MIT License

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
