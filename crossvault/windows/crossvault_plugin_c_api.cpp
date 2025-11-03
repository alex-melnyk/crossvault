#include "include/crossvault/crossvault_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "crossvault_plugin.h"

void CrossvaultPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  crossvault::CrossvaultPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
