import 'package:crossvault_platform_interface/src/options/crossvault_options.dart';
import 'package:crossvault_platform_interface/src/options/windows_persist.dart';

/// Options for Windows platform.
///
/// Provides configuration for Windows Credential Manager.
class WindowsOptions extends CrossvaultOptions {
  /// Creates Windows-specific options.
  ///
  /// [prefix] A prefix to add to all credential names.
  /// Defaults to `'crossvault'`.
  ///
  /// [persist] The persistence level for credentials.
  /// Defaults to [WindowsPersist.localMachine].
  const WindowsOptions({
    this.prefix = 'crossvault',
    this.persist = WindowsPersist.localMachine,
  });

  /// A prefix to add to all credential names.
  ///
  /// This helps organize credentials in Windows Credential Manager.
  final String prefix;

  /// The persistence level for credentials.
  final WindowsPersist persist;

  @override
  WindowsOptions merge(CrossvaultOptions? other) {
    if (other == null || other is! WindowsOptions) {
      return this;
    }
    return WindowsOptions(
      prefix: other.prefix,
      persist: other.persist,
    );
  }

  @override
  String toString() {
    return 'WindowsOptions(prefix: $prefix, persist: $persist)';
  }
}
