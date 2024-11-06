#include "include/fluidlite/fluidlite_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "fluidlite_plugin.h"

void FluidlitePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  fluidlite::FluidlitePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
