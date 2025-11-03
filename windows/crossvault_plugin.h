#ifndef FLUTTER_PLUGIN_CROSSVAULT_PLUGIN_H_
#define FLUTTER_PLUGIN_CROSSVAULT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace crossvault {

class CrossvaultPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  CrossvaultPlugin();

  virtual ~CrossvaultPlugin();

  // Disallow copy and assign.
  CrossvaultPlugin(const CrossvaultPlugin&) = delete;
  CrossvaultPlugin& operator=(const CrossvaultPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace crossvault

#endif  // FLUTTER_PLUGIN_CROSSVAULT_PLUGIN_H_
