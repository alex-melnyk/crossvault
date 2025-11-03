#ifndef FLUTTER_PLUGIN_CROSSVAULT_WINDOWS_PLUGIN_H_
#define FLUTTER_PLUGIN_CROSSVAULT_WINDOWS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace crossvault_windows {

class CrossvaultWindowsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  CrossvaultWindowsPlugin();

  virtual ~CrossvaultWindowsPlugin();

  // Disallow copy and assign.
  CrossvaultWindowsPlugin(const CrossvaultWindowsPlugin&) = delete;
  CrossvaultWindowsPlugin& operator=(const CrossvaultWindowsPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace crossvault_windows

#endif  // FLUTTER_PLUGIN_CROSSVAULT_WINDOWS_PLUGIN_H_
