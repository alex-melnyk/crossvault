import 'package:crossvault_platform_interface/crossvault_platform_interface.dart';

/// The main Crossvault plugin class.
///
/// This provides a unified API for secure vault operations across
/// Android, iOS, macOS, and Windows platforms.
class Crossvault {
  /// Returns the platform version.
  ///
  /// This is a demo method and should be replaced with actual vault functionality.
  Future<String?> getPlatformVersion() {
    return CrossvaultPlatform.instance.getPlatformVersion();
  }
}
