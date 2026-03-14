//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <dog_detection/dog_detection_plugin.h>
#include <file_selector_windows/file_selector_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DogDetectionPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DogDetectionPlugin"));
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
}
