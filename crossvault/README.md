# crossvault

A secure cross-platform vault plugin for Flutter that provides a unified API for secure storage across Android, iOS, macOS, and Windows.

## Features

- ✅ **Cross-platform**: Works on Android, iOS, macOS, and Windows
- ✅ **Federated architecture**: Each platform has its own optimized implementation
- ✅ **Type-safe**: Full Dart type safety
- ✅ **Easy to use**: Simple, consistent API across all platforms

## Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅      |
| iOS      | ✅      |
| macOS    | ✅      |
| Windows  | ✅      |
| Linux    | ⏳ Coming soon |
| Web      | ⏳ Coming soon |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  crossvault: ^0.0.1
```

## Usage

```dart
import 'package:crossvault/crossvault.dart';

final crossvault = Crossvault();

// Get platform version (demo method)
String? version = await crossvault.getPlatformVersion();
print('Running on: $version');
```

## Architecture

This plugin uses a federated architecture with the following packages:

- **crossvault**: The app-facing package that users depend on
- **crossvault_platform_interface**: The common interface that all platforms implement
- **crossvault_android**: Android implementation
- **crossvault_ios**: iOS implementation
- **crossvault_macos**: macOS implementation
- **crossvault_windows**: Windows implementation

This architecture allows for:
- Independent versioning of platform implementations
- Easier maintenance and testing
- Better separation of concerns
- Following Flutter's best practices for plugin development

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

MIT License
