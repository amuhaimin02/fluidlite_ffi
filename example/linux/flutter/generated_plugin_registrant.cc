//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <fluidlite/fluidlite_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) fluidlite_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FluidlitePlugin");
  fluidlite_plugin_register_with_registrar(fluidlite_registrar);
}
