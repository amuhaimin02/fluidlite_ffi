#ifndef FLUTTER_PLUGIN_FLUIDLITE_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUIDLITE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace fluidlite {

class FluidlitePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FluidlitePlugin();

  virtual ~FluidlitePlugin();

  // Disallow copy and assign.
  FluidlitePlugin(const FluidlitePlugin&) = delete;
  FluidlitePlugin& operator=(const FluidlitePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace fluidlite

#endif  // FLUTTER_PLUGIN_FLUIDLITE_PLUGIN_H_
