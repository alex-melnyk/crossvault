# crossvault_platform_interface

A common platform interface for the [`crossvault`][1] plugin.

This interface allows platform-specific implementations of the `crossvault`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

## Usage

To implement a new platform-specific implementation of `crossvault`, extend
[`CrossvaultPlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`CrossvaultPlatform` by calling
`CrossvaultPlatform.instance = MyCrossvaultPlatform()`.

## Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../crossvault
[2]: lib/src/crossvault_platform.dart
