#include "include/dog_detection/dog_detection_plugin.h"
#include "dog_detection_plugin.h"
#include <flutter/plugin_registrar_windows.h>

void DogDetectionPluginRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
  auto cpp_registrar =
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar);
  dog_detection::DogDetectionPlugin::RegisterWithRegistrar(cpp_registrar);
}
