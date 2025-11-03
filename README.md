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

## 🚀 Quick Start

Add `crossvault` to your `pubspec.yaml`:

```yaml
dependencies:
  crossvault: ^0.0.1
```

Then use it in your code:

```dart
import 'package:crossvault/crossvault.dart';

final crossvault = Crossvault();
String? version = await crossvault.getPlatformVersion();
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
