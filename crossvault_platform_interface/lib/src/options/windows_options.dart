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
  ///
  /// [useTPM] Whether to use TPM (Trusted Platform Module) for hardware-backed security.
  /// If `true` and TPM is available, credentials will be bound to TPM.
  /// If TPM is not available, falls back to DPAPI.
  /// Defaults to `false`.
  const WindowsOptions({
    this.prefix = 'crossvault',
    this.persist = WindowsPersist.localMachine,
    this.useTPM = false,
  });

  /// A prefix to add to all credential names.
  ///
  /// This helps organize credentials in Windows Credential Manager.
  final String prefix;

  /// The persistence level for credentials.
  final WindowsPersist persist;
  
  /// Whether to use TPM (Trusted Platform Module) for hardware-backed security.
  ///
  /// When enabled:
  /// - Credentials are bound to the TPM chip
  /// - Provides hardware-level security similar to iOS Secure Enclave
  /// - Keys cannot be extracted from the device
  /// - Automatically falls back to DPAPI if TPM is not available
  ///
  /// Requirements:
  /// - Windows 7 or later
  /// - TPM 1.2 or 2.0 chip
  /// - TPM must be enabled in BIOS
  ///
  /// **Note**: TPM-bound credentials are device-specific and cannot be
  /// transferred to another machine.
  final bool useTPM;

  @override
  WindowsOptions merge(CrossvaultOptions? other) {
    if (other == null || other is! WindowsOptions) {
      return this;
    }
    return WindowsOptions(
      prefix: other.prefix,
      persist: other.persist,
      useTPM: other.useTPM,
    );
  }

  @override
  String toString() {
    return 'WindowsOptions(prefix: $prefix, persist: $persist, useTPM: $useTPM)';
  }
}
