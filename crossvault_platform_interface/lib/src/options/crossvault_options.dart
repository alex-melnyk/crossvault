/// Base class for platform-specific options.
///
/// Each platform can extend this class to provide platform-specific configuration.
abstract class CrossvaultOptions {
  const CrossvaultOptions();

  /// Merges this options with another options.
  ///
  /// The [other] options will override values in this options.
  /// Returns a new options instance with merged values.
  CrossvaultOptions merge(CrossvaultOptions? other);
}
