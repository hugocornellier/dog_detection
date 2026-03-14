#include "include/dog_detection/dog_detection_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "dog_detection_plugin.h"

void DogDetectionPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  dog_detection::DogDetectionPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
