/// The interface that platform-specific implementations of `crossvault` must extend.
///
/// Platform implementations should extend [CrossvaultPlatform] rather than
/// implement it. Extending [CrossvaultPlatform] ensures that any new methods
/// added to the interface will have a default implementation that throws
/// [UnimplementedError], which will prevent breaking changes.
library crossvault_platform_interface;

export 'src/crossvault_options.dart';
export 'src/crossvault_platform.dart';
export 'src/method_channel_crossvault.dart';
