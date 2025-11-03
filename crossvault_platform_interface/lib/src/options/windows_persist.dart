/// Windows Credential Manager persistence levels.
///
/// Determines how credentials are persisted in Windows.
enum WindowsPersist {
  /// Credentials persist for the current login session only.
  ///
  /// The credentials are deleted when the user logs off.
  session,

  /// Credentials persist for the local machine.
  ///
  /// The credentials are available to all users on the local machine.
  localMachine,

  /// Credentials persist for the enterprise domain.
  ///
  /// The credentials are available across the enterprise domain.
  enterprise,
}
