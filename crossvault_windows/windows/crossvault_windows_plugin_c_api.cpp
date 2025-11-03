#include "include/crossvault_windows/crossvault_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "crossvault_windows_plugin.h"

void CrossvaultWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  crossvault_windows::CrossvaultWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
