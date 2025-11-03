#ifndef FLUTTER_PLUGIN_CROSSVAULT_WINDOWS_PLUGIN_H_
#define FLUTTER_PLUGIN_CROSSVAULT_WINDOWS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>
#include <string>
#include <windows.h>

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

 private:
  // Helper methods for Credential Manager operations
  std::wstring BuildTargetName(const std::string& key, const std::string& prefix);
  DWORD GetPersistType(const std::string& persist);
  
  // Credential Manager operations
  bool ExistsKey(const std::string& key, const std::string& prefix);
  std::string GetValue(const std::string& key, const std::string& prefix);
  bool SetValue(const std::string& key, const std::string& value, 
                const std::string& prefix, const std::string& persist, bool useTPM);
  bool DeleteValue(const std::string& key, const std::string& prefix);
  bool DeleteAll(const std::string& prefix);
};

}  // namespace crossvault_windows

#endif  // FLUTTER_PLUGIN_CROSSVAULT_WINDOWS_PLUGIN_H_
